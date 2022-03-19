CREATE TABLE Disciplina(
	sigla varchar(255) not null,
	nome varchar(255) not null,
	carga_horaria DECIMAL(10,2) not null,
	CONSTRAINT PK_sigladisciplina PRIMARY KEY (sigla)
)
go
CREATE TABLE Aluno(
	ra int IDENTITY(1,1) not null,
	cpf varchar(14) null, 
	nome varchar(255) null,
	CONSTRAINT PK_raAluno PRIMARY KEY(ra)
)
go
CREATE TABLE Historico(
	nota1 decimal(10,2) not null,
	nota2 decimal(10,2) not null,
	nota_sub decimal(10,2) null DEFAULT 0.0,
	media decimal(10,2) null DEFAULT 0.0,
	horas_frequencia DECIMAL(10,2) not null,
	status_conclusao varchar(255) null DEFAULT 'CURSANDO',
	ra_aluno int not null,
	sigla_disciplina varchar(255) not null,
	ano int not null,
	semestre int not null,
	CONSTRAINT PK_anoHistorico PRIMARY KEY (ra_aluno, sigla_disciplina),
	CONSTRAINT FK_ra_aluno FOREIGN KEY (ra_aluno) REFERENCES Aluno(ra),
	CONSTRAINT FK_siglaDisciplina FOREIGN KEY (sigla_disciplina) REFERENCES Disciplina(sigla)
)
go

insert into Aluno(cpf, nome)
values('501234625123', 'leonardo borges')
insert into Aluno(cpf, nome)
values('754812546985', 'Gabriel borges')
GO
insert into Disciplina(sigla, nome, carga_horaria)
values('BD1', 'Banco de dados 1', 40.0)
insert into Disciplina(sigla, nome, carga_horaria)
values('BD2', 'Banco de dados 2', 140.0)
insert into Disciplina(sigla, nome, carga_horaria)
values('SI', 'Sistemas digitais', 200.0)
insert into Disciplina(sigla, nome, carga_horaria)
values('EA1', 'Eletricidade aplicada 1', 200.0)
GO

insert into Historico(nota1, nota2, horas_frequencia, ra_aluno, sigla_disciplina, ano, semestre)
values(
	7.0,
	8.0,
	25.0,
	1,
	'BD1',
	2021,
	1
)
insert into Historico(nota1, nota2, horas_frequencia, ra_aluno, sigla_disciplina, ano, semestre)
values(
	10.0,
	10.0,
	25.0,
	1,
	'BD2',
	2021,
	2
)
insert into Historico(nota1, nota2, horas_frequencia, ra_aluno, sigla_disciplina, ano, semestre)
values(
	3.0,
	4.0,
	150.0,
	2,
	'SI',
	2022,
	1
)

insert into Historico(nota1, nota2, horas_frequencia, ra_aluno, sigla_disciplina, ano, semestre)
values(
	3.0,
	2.0,
	150.0,
	1,
	'SI',
	2021,
	1
)
insert into Historico(nota1, nota2, horas_frequencia, ra_aluno, sigla_disciplina, ano, semestre)
values(
	3.0,
	2.0,
	150.0,
	1,
	'EA1',
	2021,
	2
)
UPDATE dbo.Historico set nota_sub = 10.0 where ra_aluno = 2 and sigla_disciplina = 'SI'
UPDATE dbo.Historico set nota_sub = 4.0 where ra_aluno = 1 and sigla_disciplina = 'SI'
GO

select * from Aluno
select * from Disciplina
select * from Historico
ALUNOS_DISCIPLINAS 2021
ALUNO_BOLETIM_PROC 2021, 1, 2
ALUNOS_REPROVADOS_NOTA 2021

GO


drop table Historico, Aluno, Disciplina
go

--------------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE DEFINE_STATUS
		@NOTA1		DECIMAL(10,2),
		@NOTA2		DECIMAL(10,2),
		@NOTA_SUB	DECIMAL(10,2),
		@MEDIA		DECIMAL(10,2),
		@HORAS_FREQUENCIA DECIMAL(10,2),
		@RA_ALUNO		INT,
		@SIGLA_DISCIPLINA VARCHAR(255)
AS
BEGIN

	DECLARE 
		@CARGA_HORARIA DECIMAL(10,2)
	SELECT @CARGA_HORARIA = carga_horaria FROM dbo.Disciplina where sigla = @SIGLA_DISCIPLINA

	SET @MEDIA = (@NOTA1 + @NOTA2) / 2

	IF (@HORAS_FREQUENCIA * 100) / @CARGA_HORARIA <= 25.0
		BEGIN
			UPDATE dbo.Historico  set media = @MEDIA, status_conclusao = 'REPROVADO POR FALTA' WHERE ra_aluno = @RA_ALUNO AND sigla_disciplina = @SIGLA_DISCIPLINA
			PRINT('REPROVADO POR FALTA!!')
		END
	ELSE
		BEGIN
			IF @MEDIA >= 5.0
				BEGIN
					UPDATE dbo.Historico set status_conclusao = 'APROVADO', media = @MEDIA WHERE ra_aluno = @RA_ALUNO and sigla_disciplina = @SIGLA_DISCIPLINA
					PRINT('APROVADO!!')
				END
			ELSE 
				BEGIN
					UPDATE dbo.Historico set media = @MEDIA, status_conclusao = 'REPROVADO POR NOTA' WHERE ra_aluno = @RA_ALUNO and sigla_disciplina = @SIGLA_DISCIPLINA
					PRINT('REPROVADO POR NOTA!! O aluno podera fazer a prova substitutiva para substituir a menor nota!')
				END
		END
END
GO

--------------------------------------------------------------------------------------------------------------------

ALTER PROCEDURE UPDATE_SUBNOTA
	@NOTA1		DECIMAL(10,2),
	@NOTA2		DECIMAL(10,2),
	@NOTA_SUB	DECIMAL(10,2),
	@MEDIA		DECIMAL(10,2),
	@HORAS_FREQUENCIA DECIMAL(10,2),
	@RA_ALUNO		INT,
	@SIGLA_DISCIPLINA VARCHAR(255)
AS
BEGIN
	DECLARE
	@CARGA_HORARIA		DECIMAL(10,2)

	SELECT @CARGA_HORARIA = carga_horaria from dbo.Disciplina where sigla = @SIGLA_DISCIPLINA

	IF (@HORAS_FREQUENCIA * 100) / @CARGA_HORARIA <= 25.0
		BEGIN
			UPDATE dbo.Historico  set status_conclusao = 'REPROVADO POR FALTA' WHERE ra_aluno = @RA_ALUNO AND sigla_disciplina = @SIGLA_DISCIPLINA
		END
	ELSE
		BEGIN
			IF @NOTA_SUB > 0.0
				BEGIN 
					IF @NOTA1 > @NOTA2
						BEGIN
							SET @MEDIA = (@NOTA1 + @NOTA_SUB) / 2 
						END
					ELSE 
						BEGIN
							SET @MEDIA = (@NOTA2 + @NOTA_SUB) / 2
						END

					IF @MEDIA > 5.0
						BEGIN
							UPDATE dbo.Historico set status_conclusao = 'APROVADO', media = @MEDIA WHERE ra_aluno = @RA_ALUNO and sigla_disciplina = @SIGLA_DISCIPLINA
							PRINT('APROVADO!!')
						END
					ELSE
						BEGIN
							UPDATE dbo.Historico set status_conclusao = 'REPROVADO POR NOTA', media = @MEDIA WHERE ra_aluno = @RA_ALUNO and sigla_disciplina = @SIGLA_DISCIPLINA
						END
				END
		END
END
GO
--------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE ALUNOS_DISCIPLINAS
	@ANO int
AS
BEGIN
	SELECT H.ra_aluno as [RA], A.nome as [NOME_ALUNO],D.nome as [NOME_DISCIPLINA] ,H.nota1 as [NOTA1], H.nota2 as [NOTA2], H.nota_sub as [NOTA_SUB], H.media as [MEDIA],
	H.horas_frequencia as [HORAS_FREQUENCIA], H.status_conclusao [SITUACAO_FINAL]
	from  Historico H 
	join Aluno A on H.ra_aluno = A.ra 
	join Disciplina D on H.sigla_disciplina = D.sigla
	where H.ano = @ANO
END
GO
-------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ALUNOS_REPROVADOS_NOTA
	@ANO int
AS
BEGIN
	SELECT H.ra_aluno as [RA], A.nome as [NOME_ALUNO], D.nome as [NOME_DISCIPLINA] , H.media as [MEDIA], H.status_conclusao [SITUACAO_FINAL]
	from  Historico H 
	join Aluno A on H.ra_aluno = A.ra 
	join Disciplina D on H.sigla_disciplina = D.sigla
	where H.ano = @ANO and H.media < 5
END
GO
--------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ALUNO_BOLETIM_PROC
	@ANO INT,
	@RA INT,
	@SEMESTRE INT
AS
BEGIN
	SELECT H.ra_aluno as [RA], A.nome as [NOME_ALUNO],D.nome as  [NOME_DISCIPLINA] ,H.nota1 as [NOTA1], H.nota2 as [NOTA2], H.nota_sub as [NOTA_SUB], H.media as [MEDIA],
	H.horas_frequencia as [HORAS_FREQUENCIA], H.status_conclusao as [SITUACAO_FINAL], H.ano as [ANO], H.Semestre as [SEMESTRE]
	from  Historico H 
	join Aluno A on H.ra_aluno = A.ra 
	join Disciplina D on H.sigla_disciplina = D.sigla
	where H.ano = @ANO and H.ra_aluno = @RA and H.semestre = @SEMESTRE
END
GO
--------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER TRG_HISTORICO_UPDATE_AI
ON dbo.Historico
AFTER UPDATE
AS
BEGIN
	DECLARE 
		@NOTA1		DECIMAL(10,2),
		@NOTA2		DECIMAL(10,2),
		@NOTA_SUB	DECIMAL(10,2),
		@MEDIA		DECIMAL(10,2),
		@HORAS_FREQUENCIA DECIMAL(10,2),
		@RA_ALUNO		INT,
		@SIGLA_DISCIPLINA VARCHAR(255)
	
	SELECT
		@NOTA1 = nota1,
		@NOTA2 = nota2,
		@NOTA_SUB = nota_sub,
		@MEDIA = media,
		@HORAS_FREQUENCIA = horas_frequencia,
		@RA_ALUNO = ra_aluno,
		@SIGLA_DISCIPLINA = sigla_disciplina
	FROM inserted
	EXECUTE UPDATE_SUBNOTA @NOTA1, @NOTA2, @NOTA_SUB, @MEDIA, @HORAS_FREQUENCIA , @RA_ALUNO, @SIGLA_DISCIPLINA 

END
GO
--------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER TRG_HISTORICO_AI
ON dbo.Historico
AFTER INSERT
AS
BEGIN
	DECLARE 
		@NOTA1		DECIMAL(10,2),
		@NOTA2		DECIMAL(10,2),
		@NOTA_SUB	DECIMAL(10,2),
		@MEDIA		DECIMAL(10,2),
		@HORAS_FREQUENCIA DECIMAL(10,2),
		@RA_ALUNO		INT,
		@SIGLA_DISCIPLINA VARCHAR(255)
	
	SELECT
		@NOTA1 = nota1,
		@NOTA2 = nota2,
		@NOTA_SUB = nota_sub,
		@MEDIA = media,
		@HORAS_FREQUENCIA = horas_frequencia,
		@RA_ALUNO = ra_aluno,
		@SIGLA_DISCIPLINA = sigla_disciplina
	FROM inserted
	EXECUTE DEFINE_STATUS @NOTA1, @NOTA2, @NOTA_SUB, @MEDIA, @HORAS_FREQUENCIA , @RA_ALUNO, @SIGLA_DISCIPLINA 

END
GO