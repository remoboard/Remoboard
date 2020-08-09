#ifndef MYTEXTEDIT_H
#define MYTEXTEDIT_H

#include <QTextEdit>
#include <QKeyEvent>


enum class MyTextKeyType {
    Delete,
    Return,
    Left,
    Right,
    Up,
    Down,
};

class MyTextEdit : public QTextEdit
{
    Q_OBJECT
public:
    explicit MyTextEdit(QWidget *parent = nullptr);
    virtual ~MyTextEdit();

    virtual void keyPressEvent(QKeyEvent *event) override;

signals:
    bool myTextKeyPressed(MyTextEdit *textEdit, MyTextKeyType key);
};

#endif // MYTEXTEDIT_H
