//
//  httpserver.cpp
//  httpdemo
//
//  Created by everettjf on 2019/9/22.
//  Copyright © 2019 everettjf. All rights reserved.
//

#include "httpserver.hpp"
#include <thread>

#include "mongoose.h"


namespace bifrost {
    static sig_atomic_t s_signal_received = 0;

    static void ev_handler(mg_connection *nc, int ev, void *ev_data, void *user_data) {
        bifrost::HttpServer *server = static_cast<bifrost::HttpServer*>(user_data);
        server->_event_handler(nc, ev, ev_data);
    }
    
    static void signal_handler(int sig_num) {
        signal(sig_num, signal_handler);  // Reinstantiate signal handler
        s_signal_received = sig_num;
    }
    
    static int is_websocket(const mg_connection *nc) {
        return nc->flags & MG_F_IS_WEBSOCKET;
    }

    struct HttpServer::Impl {
        std::thread server_thread;
        std::string port;
        std::string root_dir;
        
        ::mg_mgr mgr;
        ::mg_connection *nc;
        
        mg_serve_http_opts http_server_opts;
        
        bool stop = false;
    };
    
    HttpServer & HttpServer::instance() {
        static HttpServer o;
        return o;
    }
    
    HttpServer::HttpServer() : _impl(std::make_shared<Impl>()) {
        _impl->port = "7777";
        _impl->root_dir = ".";
        memset(&_impl->http_server_opts, 0, sizeof(_impl->http_server_opts));
    }
    
    HttpServer::~HttpServer() {
        close();
    }
    
    void HttpServer::set_root_dir(const std::string & dir) {
        _impl->root_dir = dir;
    }
    
    void HttpServer::set_port(const std::string & port) {
        _impl->port = port;
    }
    
    
    void HttpServer::run() {
        close();
        
        _impl->server_thread = std::thread([&]() {
            internalRun();
        });
    }
    
    void HttpServer::internalRun() {
        _impl->stop = false;
        
        signal(SIGTERM, signal_handler);
        signal(SIGINT, signal_handler);
        setvbuf(stdout, NULL, _IOLBF, 0);
        setvbuf(stderr, NULL, _IOLBF, 0);
        
        mg_mgr_init(&_impl->mgr, NULL);
        
        _impl->nc = mg_bind(&_impl->mgr, _impl->port.c_str(), ev_handler, (void*)this);
        mg_set_protocol_http_websocket(_impl->nc);
        _impl->http_server_opts.document_root = _impl->root_dir.c_str();
        _impl->http_server_opts.enable_directory_listing = "no";
        
        printf("Started on port %s\n", _impl->port.c_str());
        while (s_signal_received == 0 && !_impl->stop) {
            mg_mgr_poll(&_impl->mgr, 200);
        }
        mg_mgr_free(&_impl->mgr);
    }
    void HttpServer::close() {
        _impl->stop = true;
        if (_impl->server_thread.joinable()) {
            _impl->server_thread.join();
        }
    }

    void HttpServer::_event_handler(void *pnc, int ev, void *ev_data) {
        mg_connection *nc = static_cast<mg_connection*>(pnc);
        
        switch (ev) {
            case MG_EV_WEBSOCKET_HANDSHAKE_DONE: {
                /* New websocket connection. Tell everybody. */
                _broadcast(nc, "++ joined");
                break;
            }
            case MG_EV_WEBSOCKET_FRAME: {
                websocket_message *wm = (struct websocket_message *) ev_data;
                /* New websocket message. Tell everybody. */
                mg_str d = {(char *) wm->data, wm->size};
                
                std::string msg(d.p,d.len);
                printf("receive:%s\n",msg.c_str());
                
                if (onMessage) {
                    onMessage(msg);
                }
                
                break;
            }
            case MG_EV_HTTP_REQUEST: {
                http_message *hm = (struct http_message *) ev_data;

                if (mg_vcmp(&hm->uri, "/api") == 0) {
                    _handle_api(nc, hm); /* Handle RESTful call */
                } else {
                    mg_serve_http(nc, hm, _impl->http_server_opts);
                }
                break;
            }
            case MG_EV_CLOSE: {
                /* Disconnect. Tell everybody. */
                if (is_websocket(nc)) {
                    _broadcast(nc, "-- left");
                }
                break;
            }
        }
    }
    
    void HttpServer::_broadcast(void *pnc,const std::string & data) {
        mg_connection *nc = (mg_connection*)pnc;
        mg_str msg = mg_mk_str(data.c_str());
        
        mg_connection *c;
        char buf[500];
        char addr[32];
        mg_sock_addr_to_str(&nc->sa, addr, sizeof(addr),
                            MG_SOCK_STRINGIFY_IP | MG_SOCK_STRINGIFY_PORT);
        
        snprintf(buf, sizeof(buf), "%s %.*s", addr, (int) msg.len, msg.p);
        printf("%s\n", buf); /* Local echo. */
        for (c = mg_next(nc->mgr, NULL); c != NULL; c = mg_next(nc->mgr, c)) {
            if (c == nc) continue; /* Don't send to the sender. */
            mg_send_websocket_frame(c, WEBSOCKET_OP_TEXT, buf, strlen(buf));
        }
    }

    void HttpServer::broadcast(const std::string & data) {
        mg_str msg = mg_mk_str(data.c_str());
        mg_connection *nc = _impl->nc;
        for (mg_connection *c = mg_next(nc->mgr, NULL); c != NULL; c = mg_next(nc->mgr, c)) {
            mg_send_websocket_frame(c, WEBSOCKET_OP_TEXT, msg.p, strlen(msg.p));
        }
    }


    void HttpServer::_handle_api( void *pnc,  void *phm) {
        mg_connection *nc = (mg_connection*)pnc;
        http_message *hm = (http_message*)phm;
        
        char msg[1000];

        /* Get form variables */
        mg_get_http_var(&hm->body, "msg", msg, sizeof(msg));
        
        std::string stdmsg(msg);
        printf("api_receive:%s\n",stdmsg.c_str());
        
        if (onMessage) {
            onMessage(stdmsg);
        }

        /* Send headers */
        mg_printf(nc, "%s", "HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n");

        /* Compute the result and send it back as a JSON object */
        mg_printf_http_chunk(nc, "{ \"result\": %d }", 0);

        mg_send_http_chunk(nc, "", 0); /* Send empty chunk, the end of response */
    }

}
