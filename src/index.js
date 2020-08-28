// var {parse} = require("./jison/parser")
import parse from "./jison/parser.js";

// const ast = parse("pyed_xiaoai_tb_name_receiver_no_client!=null&&pyed_xiaoai_tb_receiver_no_client_loan_name!=null&&!(pyed_xiaoai_tb_name_receiver_no_client.equals(pyed_xiaoai_tb_receiver_no_client_loan_name))  && (sp_random_num_06!=null&&sp_random_num_06>=5000)&&$dec.contains(pyed_xiaoai_tb_name_receiver_no_client,pysp_xiaoai_name) && (sp_random_num_06!=null&&sp_random_num_06>=5000)")
const ast = parse(`
pyed_xiaoai_tb_name_receiver_no_client!=null
|| pyed_xiaoai_tb_receiver_no_client_loan_name!=null
&&!(
  pyed_xiaoai_tb_name_receiver_no_client.equals(
    pyed_xiaoai_tb_receiver_no_client_loan_name
  )
)  
&& (sp_random_num_06!=null&&sp_random_num_06>=5000)
|| $dec.contains(
  pyed_xiaoai_tb_name_receiver_no_client
  ,pysp_xiaoai_name
) 
||  (
  sp_random_num_06!=null
  &&sp_random_num_06>=5000
)

`);
console.log(ast)
console.log(ast.toString())
//
// const ast2 = parse("! $dec.contains(a,b)")
// console.log(ast2)
// console.log(ast2.toString())
//
// const ast3 = parse("!      $dec.contains(a,b)")
// console.log(ast3)
// console.log(ast3.toString())
//
// const ast4 = parse("true")
// console.log(ast4)
// console.log(ast4.toString())
//
// const ast5 = parse("null")
// console.log(ast5)
// console.log(ast5.toString())

// const ast5 = parse("$dec.containsAll(testww,\"7\")&&$dec.containsAll(testww,\"7\")==false")
// const ast5 = parse("定义常量姓名为&&'牛春雷'")
// const ast5 = parse("abc&&def")
// console.log(ast5)
// console.log(ast5.toString())

// console.log(parse("$dec.contains(a,b)"))

// var abc = "var";
// const isNum = typeof abc === 'number';

// 声明 变量 abc 为 字符串“var”；
// 声明 常量 isNum 为 校验abc类型全等于“number”的值；


// A && B && C && D || E || F
const simpleAST = {
    type: '||',
    left: {
        type: '||',
        left: {
            type: '&&',
            left: {
                type: '&&',
                left: {
                    type: '&&',
                    left: {
                        type: 'exp',
                        expression: 'A'
                    },
                    right: {
                        type: 'exp',
                        expression: 'B'
                    }
                },
                right: {
                    type: 'exp',
                    expression: 'C'
                }
            },
            right: {
                type: 'exp',
                expression: 'D'
            }
        },
        right: {
            type: 'exp',
            expression: 'E'
        }
    },
    right: {
        type: 'exp',
        expression: 'F'
    }
};

// 示例，定义结构
const construct = {
    operation: '||',
    children: [],
}

const handleFunc = (AST) => {
    if (AST.type === 'exp') {   // 如果是叶子结点
        return AST;
    } else {
        const tempLeft = handleFunc(AST.left);
        const tempRight = handleFunc(AST.right);
        if (!tempLeft.operation && !tempRight.operation) {  // 左右均为叶子结点
            return {
                operation: AST.type,
                children: [tempLeft, tempRight]
            };
        } else if (tempLeft.operation && !tempRight.operation) {    // 仅右边为叶子结点
            if (tempLeft.operation === AST.type) {  // 如果下层结点与本层结点的操作符相同，合并
                return {
                    operation: AST.type,
                    children: [...tempLeft.children, tempRight]
                };
            } else {  // 如果下层结点与本层结点的操作符相同，不可合并
                return {
                    operation: AST.type,
                    children: [tempLeft, tempRight]
                };
            }
        } else if (!tempLeft.operation && tempRight.operation) {    // 仅左边为叶子结点
            if (tempRight.operation === AST.type) {  // 如果下层结点与本层结点的操作符相同，合并
                return {
                    operation: AST.type,
                    children: [tempLeft, ...tempRight.children]
                };
            } else {  // 如果下层结点与本层结点的操作符相同，不可合并
                return {
                    operation: AST.type,
                    children: [tempLeft, tempRight]
                };
            }
        } else {    // 均不为叶子结点
            if (tempLeft.operation === tempRight.operation === AST.type) {  // 如果左右根结点都相同
                return {
                    operation: AST.type,
                    children: [...tempLeft.children, ...tempRight.children]
                }
            } else if (tempLeft.operation === AST.type) {   // 如果左根结点相同
                return {
                    operation: AST.type,
                    children: [...tempLeft.children, tempRight]
                }
            } else if (tempLeft.operation === AST.type) {   // 如果右根结点相同
                return {
                    operation: AST.type,
                    children: [tempLeft, ...tempRight.children]
                }
            } else {
                return {
                    operation: AST.type,
                    children: [tempLeft, tempRight]
                }
            }
        }
    }
}

console.log(handleFunc(simpleAST));

const drawExpression = (data) => {
    return `
        <div class="container">
            <div><span>${data.operation}</span></div>
            <div>
                ${data.children.map(item => {
                    if (item.operation) {
                        return drawExpression(item);
                    } else {
                        return `
                            <div class="expression"><span>${item.expression}</span></div>
                        `;
                    }
                }).join('')}
            </div>
        </div>
    `;
};

document.body.innerHTML = drawExpression(handleFunc(simpleAST));