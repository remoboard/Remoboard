#include "mainapp.h"

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(remotekb);

    MainApp a(argc, argv);
    return a.exec();
}
