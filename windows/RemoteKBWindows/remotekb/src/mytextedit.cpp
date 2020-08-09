#include "mytextedit.h"


MyTextEdit::MyTextEdit(QWidget *parent):
    QTextEdit (parent)
{

}

MyTextEdit::~MyTextEdit()
{

}

void MyTextEdit::keyPressEvent(QKeyEvent *event)
{
    bool ignore = false;
    if (event->key() == Qt::Key_Return) {
        ignore = emit myTextKeyPressed(this, MyTextKeyType::Return);
    } else if(event->key() == Qt::Key_Backspace) {
        ignore = emit myTextKeyPressed(this, MyTextKeyType::Delete);
    } else if(event->key() == Qt::Key_Left) {
        ignore = emit myTextKeyPressed(this, MyTextKeyType::Left);
    } else if(event->key() == Qt::Key_Right) {
        ignore = emit myTextKeyPressed(this, MyTextKeyType::Right);
    } else if(event->key() == Qt::Key_Up) {
        ignore = emit myTextKeyPressed(this, MyTextKeyType::Up);
    } else if(event->key() == Qt::Key_Down) {
        ignore = emit myTextKeyPressed(this, MyTextKeyType::Down);
    }
    if (ignore) {
        return;
    }
    QTextEdit::keyPressEvent(event);
}
