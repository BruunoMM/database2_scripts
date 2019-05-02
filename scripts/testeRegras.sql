--------------------------TESTES REGRAS----------------------------------
--Toda vez que o estoque de uma mercadoria estiver abaixo de um dado valor, deve ser
--enviado um e-mail para o administrador do sistema de compras, indicando que o pedido de
--um produto deve ser realizado. 
  
INSERT INTO mercadorias (numeromercadoria, descricao, quantidadeestoque, estoquemin, estoquemax, precomin)
VALUES (2, 'TesteMin', 0, 5, 20, 3);

--Deve ser implementada regra que impeça que o preço de venda de um produto seja menor
--que o preço da última compra realizada para o produto em questão. 

INSERT INTO mercadorias (numeromercadoria, descricao, quantidadeestoque, estoquemin, estoquemax, precomin)
VALUES (3, 'TesteRegra', 10, 5, 20, 1);

  INSERT INTO notascompra (numero, dataemissao, fornecedorid)
VALUES (2, null, 1);

 INSERT INTO itensnotacompra (numero, numeroMercadoria, quantidade, valorunitario)
 VALUES (2, 3, 5, 5);

INSERT INTO itensnota (numero, numeromercadoria, quantidade, valorunitario)
VALUES (1, 3, 5, 4);

--Não deve ser possível realizar vendas de produtos sem estoque. 

INSERT INTO mercadorias (numeromercadoria, descricao, quantidadeestoque, estoquemin, estoquemax, precomin)
VALUES (4, 'TesteEstoque', 2, 5, 20, 1);

INSERT INTO itensnota (numero, numeromercadoria, quantidade, valorunitario)
VALUES (1, 4, 5, 4);

--Não deve ser possível realizar aquisições que façam com que um produto ultrapasse seu
--estoque máximo. 

INSERT INTO mercadorias (numeromercadoria, descricao, quantidadeestoque, estoquemin, estoquemax, precomin)
VALUES (5, 'TesteEstoque2', 2, 5, 20, 1);

  INSERT INTO notascompra (numero, dataemissao, fornecedorid)
VALUES (3, null, 1);

INSERT INTO itensnotacompra (numero, numeroMercadoria, quantidade, valorunitario)
 VALUES (3, 5, 50, 5);
