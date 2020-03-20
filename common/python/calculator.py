#!/usr/bin/env python
# encoding: utf-8


# 输入字符串处理
class Buffer(object):
    def __init__(self, data):
        self.data = data
        self.offset = 0

    # 提取offset位置处的一个字符
    def peek(self):
        # 如果没有后续字符则返回None
        if self.offset >= len(self.data):
            return None
        return self.data[self.offset]

    # 取字符的位置向后移动一位
    def advance(self):
        self.offset += 1


# 定义字符节点
class Token(object):
    def consume(self, buffer):
        pass


# 整数类型的Token
class TokenInt(Token):
    # 从字符串中读取字符直到字符不是整数
    def consume(self, buffer):
        accum = ""
        while True:
            ch = buffer.peek()
            if ch is None or ch not in "0123456789":
                break
            else:
                accum += ch
                buffer.advance()
        # 如果读取的内容不为空则返回整数，否则返回None
        if accum != "":
            return ("int", int(accum))
        else:
            return None


# 操作（+，-）类型的Token
class TokenOperator(Token):
    # 读取一个字符，然后返回这个字符，如果字符不是+-，则返回None
    def consume(self, buffer):
        ch = buffer.peek()
        if ch is not None and ch in "+-":
            buffer.advance()
            return ("ope", ch)
        return None


# 表达式二叉树的节点
class Node(object):
    pass


# 整数节点
class NodeInt(Node):
    def __init__(self, value):
        self.value = value


# 操作符节点 (+ 或 -)
class NodeBinaryOp(Node):
    def __init__(self, kind):
        self.kind = kind
        self.left = None    # 左节点
        self.right = None   # 右节点


# 从字符串中获取整数及操作的Token
def tokenize(string):
    buffer = Buffer(string)
    tk_int = TokenInt()
    tk_op = TokenOperator()
    tokens = []

    while buffer.peek():
        token = None
        # 用两种类型的Token进行测试
        for tk in (tk_int, tk_op):
            token = tk.consume(buffer)
            if token:
                tokens.append(token)
                break
        # 如果不存在可以识别的Token表示输入错误
        if not token:
            raise ValueError("Error in syntax")
    return tokens


# 从Token列表生成表达式二叉树
def parse(tokens):
    if tokens[0][0] != 'int':
        raise ValueError("Must start with an int")
    #取出tokens[0]，该Token类型为整数
    node = NodeInt(tokens[0][1])
    nbo = None
    last = tokens[0][0]
    #从第二个Token开始循环取出
    for token in tokens[1:]:
        #相邻两个Token的类型一样则为错误
        if token[0] == last:
            raise ValueError("Error in syntax")
        last = token[0]
        #如果Token为操作符，则保存为操作符节点，把前一个整数Token作为左子节点
        if token[0] == 'ope':
            nbo = NodeBinaryOp(token[1])
            nbo.left = node
        #如果Token为整数，则将该Token保存为右节点
        if token[0] == 'int':
            nbo.right = NodeInt(token[1])
            node = nbo
    return node


# 采用递归的方法计算表达式二叉树的值
def calculate(nbo):
    # 如果左节点是二叉树，则先计算左节点二叉树的值
    if isinstance(nbo.left, NodeBinaryOp):
        leftval = calculate(nbo.left)
    else:
        leftval = nbo.left.value
    # 根据操作符节点是加还是减计算
    if nbo.kind == '-':
        return leftval - nbo.right.value
    elif nbo.kind == '+':
        return leftval + nbo.right.value
    else:
        raise ValueError("Wrong operator")


# 判断是否只输入了一个整数
def evaluate(node):
    # 如果表达式中只有一个整数，则直接返回值
    if isinstance(node, NodeInt):
        return node.value
    else:
        return calculate(node)


# 主程序，输入输出处理
def main():
    input = raw_input('Input:')
    print(operate(input)


if __name__ == '__main__':
    # 获取输入字符串
    input = raw_input('Input:')
    # 从输入字符串获得Token列表
    tokens = tokenize(input)
    # 从Token列表生成表达式树
    node = parse(tokens)
    # 遍历计算表达式树并输出结果
    print("Result:"+str(evaluate(node)))
