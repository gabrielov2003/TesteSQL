#Criei minha database para este projeto e dentro da pasta coloquei todas as tabelas .csv
CREATE DATABASE tabelas;
USE tabelas;

#Criei esta tabela para fazer uma relação entre a razão social e o registro ANS de cada empresa
DROP TABLE relatorio_cadop;
CREATE TABLE relatorio_cadop (
	reg_ans DECIMAL(10,0) NOT NULL,
    razao_social VARCHAR(255) NOT NULL
);

#Carreguei os dados do registro ANS e a razão social para a tabela da database
LOAD DATA INFILE 'Relatorio_cadop.csv'
INTO TABLE relatorio_cadop
CHAR SET latin1
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' STARTING BY ''
IGNORE 3 ROWS 
(reg_ans, @dummy, razao_social, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, 
@dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy, @dummy);

SELECT * FROM relatorio_cadop;

-- -----------------------------------------------------------------------------------------------

#Criei uma tabela para a despesa das empresas no último trimestre e outra do ano de 2020 inteiro
DROP TABLE tabela_despesas_tri;
DROP TABLE tabela_despesas_ano;
CREATE TABLE tabela_despesas_tri (
	data_saldo DATE NOT NULL,
    reg_ans DECIMAL(10,0) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    saldo DECIMAL(15,2)
);
CREATE TABLE tabela_despesas_ano (
	data_saldo DATE NOT NULL,
    reg_ans DECIMAL(10,0) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    saldo DECIMAL(15,2)
);

#Carreguei os dados na tabela do primeiro trimestre de 2021
LOAD DATA INFILE '1T2021.csv' INTO TABLE tabela_despesas_tri CHAR SET latin1
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' STARTING BY ''
IGNORE 1 ROWS
(@data_saldo, reg_ans, @dummy, descricao, @saldo) SET data_saldo = STR_TO_DATE(@data_saldo, '%d/%m/%Y'), saldo = REPLACE(@saldo, ',', '.');

#Caso receba o erro 2013 vá em Edit > Preferences > SQL Editor > Aumente "DBMS connection read time out value." para 60

#Carreguei os dados de todos os trimestres de 2020
LOAD DATA INFILE '1T2020.csv' INTO TABLE tabela_despesas_ano CHAR SET latin1
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' STARTING BY ''
IGNORE 1 ROWS
(@data_saldo, reg_ans, @dummy, descricao, @saldo) SET data_saldo = STR_TO_DATE(@data_saldo, '%d/%m/%Y'), saldo = REPLACE(@saldo, ',', '.');
LOAD DATA INFILE '2T2020.csv' INTO TABLE tabela_despesas_ano CHAR SET latin1
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' STARTING BY ''
IGNORE 1 ROWS
(@data_saldo, reg_ans, @dummy, descricao, @saldo) SET data_saldo = STR_TO_DATE(@data_saldo, '%d/%m/%Y'), saldo = REPLACE(@saldo, ',', '.');
LOAD DATA INFILE '3T2020.csv' INTO TABLE tabela_despesas_ano CHAR SET latin1
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' STARTING BY ''
IGNORE 1 ROWS
(@data_saldo, reg_ans, @dummy, descricao, @saldo) SET data_saldo = STR_TO_DATE(@data_saldo, '%d/%m/%Y'), saldo = REPLACE(@saldo, ',', '.');
LOAD DATA INFILE '4T2020.csv' INTO TABLE tabela_despesas_ano CHAR SET latin1
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' STARTING BY ''
IGNORE 1 ROWS
(@data_saldo, reg_ans, @dummy, descricao, @saldo) SET data_saldo = STR_TO_DATE(@data_saldo, '%d/%m/%Y'), saldo = REPLACE(@saldo, ',', '.');

SELECT * FROM tabela_despesas_tri;
SELECT * FROM tabela_despesas_ano;

-- --------------------------------------------------------------------------------------------

#Criei uma tabela com as empresas que mais tiveram gastos com "EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR" 
# no último e outra para apenas o último trimestre
DROP TABLE tabela_rank_ano;
DROP TABLE tabela_rank_tri;
CREATE TABLE tabela_rank_ano (
	data_saldo DATE,
    reg_ans DECIMAL(10,0) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    saldo DECIMAL(15,2)
);
CREATE TABLE tabela_rank_tri (
	data_saldo DATE,
    reg_ans DECIMAL(10,0) NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    saldo DECIMAL(15,2)
);

#Carreguei todos os dados nescessarios fazendo as alterações nescessárias para ficar em ordem e somando os saldos no trimeste
INSERT INTO tabela_rank_tri
SELECT data_saldo, tabela_despesas_tri.reg_ans, relatorio_cadop.razao_social, SUM(tabela_despesas_tri.saldo) as saldo
FROM relatorio_cadop
INNER JOIN tabela_despesas_tri
ON tabela_despesas_tri.reg_ans = relatorio_cadop.reg_ans AND tabela_despesas_tri.descricao like '%EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR%'
GROUP BY tabela_despesas_tri.reg_ans
ORDER BY saldo DESC;

#Carreguei todos os dados nescessarios fazendo as alterações nescessárias para ficar em ordem e somando os saldos no ano
INSERT INTO tabela_rank_ano
SELECT data_saldo, tabela_despesas_ano.reg_ans, relatorio_cadop.razao_social, SUM(tabela_despesas_ano.saldo) as saldo
FROM relatorio_cadop
INNER JOIN tabela_despesas_ano
ON tabela_despesas_ano.reg_ans = relatorio_cadop.reg_ans AND tabela_despesas_ano.descricao like '%EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR%'
GROUP BY tabela_despesas_ano.reg_ans
ORDER BY saldo DESC;

#As 10 operadoras que mais tiveram despesas com "EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR" no último trimestre:
SELECT * FROM tabela_rank_tri LIMIT 10;
#As 10 operadoras que mais tiveram despesas com "EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS  DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR" no último ano?
SELECT * FROM tabela_rank_ano LIMIT 10;