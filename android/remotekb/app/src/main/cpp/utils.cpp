//
// Created by everettjf on 2019-09-29.
//

#include "utils.h"
#include <unistd.h>
#include "networkhandler.h"
#include "dep/logic/tinyformat.h"
#include "dep/logic/anybase.h"
#include <boost/algorithm/string.hpp>
#include <vector>
#include <boost/lexical_cast.hpp>

namespace utils {


std::string ip2code(const std::string & ip) {
    std::vector<std::string> result;
    boost::split(result, ip, boost::is_any_of("."));
    if (result.size() != 4) {
        return "";
    }

    int n0=0,n1=0,n2=0,n3=0;
    try {
        n0 = boost::lexical_cast<int>(result[0]);
        n1 = boost::lexical_cast<int>(result[1]);
        n2 = boost::lexical_cast<int>(result[2]);
        n3 = boost::lexical_cast<int>(result[3]);
    }catch(const boost::bad_lexical_cast &) {
        return "";
    }

    if (n0 == 192 && n1 == 168) {
        long codeBase10 = n2 * 256 + n3;

        std::string codeBase36 = anybase::Decimal2AnyBase(codeBase10, 32);
        return tfm::format("x%s",codeBase36);
    } else {
        long codeBase10 = n0 * 256 * 256 * 256 +
                          n1 * 256 * 256 +
                          n2 * 256 +
                          n3;

        std::string codeBase36 = anybase::Decimal2AnyBase(codeBase10, 32);
        return codeBase36;
    }
}

}
