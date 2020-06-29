-- Database: PracticaArchivos

-- DROP DATABASE "PracticaArchivos";
--Inciso 1
--Generar el script que crea cada una de las tablas que conforman la base de datos propuesta por el Comité Olímpico
CREATE DATABASE "PracticaArchivos"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Spain.1252'
    LC_CTYPE = 'Spanish_Spain.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE "PracticaArchivos"
    IS 'Practica de archivos en junio 2020';
	
create table PROFESION(
	cod_prof integer not null,
	nombre varchar(50) unique not null
);
alter table profesion add primary key(cod_prof);

create table PAIS(
	cod_pais integer not null,
	nombre varchar(50) unique not null
);
alter table pais add primary key(cod_pais);

create table PUESTO(
	cod_puesto integer not null,
	nombre varchar(50) unique not null
);
alter table puesto add primary key(cod_puesto);

create table DEPARTAMENTO(
	cod_depto integer not null,
	nombre varchar(50) unique not null
);
alter table departamento add primary key(cod_depto);

create table MIEMBRO(
	cod_miembro integer not null,
	nombre varchar(100) not null,
	apellido varchar(100) not null,
	edad integer not null,
	telefono integer, 
	residencia varchar(100),
	cod_pais integer not null,
	cod_prof integer not null
);
alter table miembro add primary key(cod_miembro);
alter table miembro add constraint PAIS_cod_pais foreign key (cod_pais)	references PAIS (cod_pais);
alter table miembro add constraint PROFESION_cod_prof foreign key (cod_prof) references PROFESION (cod_prof);

create table PUESTO_MIEMBRO(
	cod_miembro integer not null,
	cod_puesto integer not null,
	cod_depto integer not null,
	fecha_inicio date not null,
	fecha_fin date
);
alter table puesto_miembro add constraint MIEMBRO_cod_miembro foreign key (cod_miembro)	references MIEMBRO (cod_miembro);
alter table puesto_miembro add constraint PUESTO_cod_puesto foreign key (cod_puesto) references PUESTO (cod_puesto);
alter table puesto_miembro add constraint DEPARTAMENTO_cod_depto foreign key (cod_depto) references DEPARTAMENTO (cod_depto);
alter table puesto_miembro add primary key(cod_miembro, cod_puesto, cod_depto);

create table TIPO_MEDALLA(
	cod_tipo integer not null,
	medalla varchar(20) not null unique
);
alter table tipo_medalla add primary key (cod_tipo);

create table MEDALLERO(
	cod_pais integer not null,
	cantidad_medallas integer not null,
	cod_tipo integer not null
);
alter table medallero add primary key (cod_pais, cod_tipo);
alter table medallero add constraint PAIS_cod_pais foreign key (cod_pais) references PAIS(cod_pais);
alter table medallero add constraint TIPO_MEDALLA_cod_tipo foreign key (cod_tipo) references TIPO_MEDALLA(cod_tipo);

create table DISCIPLINA(
	cod_disciplina integer not null,
	nombre varchar(50) not null,
	descripcion varchar(150)
);
alter table disciplina add primary key (cod_disciplina);

create table ATLETA(
	cod_atleta integer not null,
	nombre varchar(50) not null,
	apellido varchar(50) not null,
	edad integer not null,
	participaciones varchar(100) not null,
	cod_disciplina integer not null,
	cod_pais integer not null
);
alter table atleta add primary key (cod_atleta);
alter table atleta add constraint DISCIPLINA_cod_disciplina foreign key (cod_disciplina) references DISCIPLINA (cod_disciplina);
alter table atleta add constraint PAIS_cod_pais foreign key (cod_pais) references PAIS (cod_pais);

create table CATEGORIA(
	cod_categoria integer not null, 
	categoria varchar(50) not null
);
alter table categoria add primary key (cod_categoria);

create table TIPO_PARTICIPACION(
	cod_participacion integer not null, 
	tipo_participacion varchar(100) not null
);
alter table tipo_participacion add primary key (cod_participacion);

create table EVENTO(
	cod_evento integer not null,
	fecha date not null,
	ubicacion varchar(50) not null,
	hora time not null,
	cod_disciplina integer not null,
	cod_participacion integer not null,
	cod_categoria integer not null 
);
alter table evento add primary key (cod_evento);
alter table evento add constraint DISCIPLINA_cod_disciplina foreign key (cod_disciplina) references DISCIPLINA(cod_disciplina);
alter table evento add constraint CATEGORIA_cod_categoria foreign key (cod_categoria) references CATEGORIA(cod_categoria);

create table EVENTO_ATLETA(
	cod_atleta integer not null,
	cod_evento integer not null
);
alter table evento_atleta add primary key (cod_atleta, cod_evento);
alter table evento_atleta add constraint ATLETA_cod_atleta foreign key (cod_atleta) references ATLETA (cod_atleta);
alter table evento_atleta add constraint EVENTO_cod_evento foreign key (cod_evento) references EVENTO (cod_evento);

create table TELEVISORA(
	cod_televisora integer not null,
	nombre varchar(50) not null
);
alter table televisora add primary key (cod_televisora);

create table COSTO_EVENTO(
	cod_evento integer not null,
	cod_televisora integer not null,
	tarifa numeric not null
);
alter table costo_evento add primary key (cod_evento, cod_televisora);
alter table costo_evento add constraint EVENTO_cod_evento foreign key (cod_evento) references EVENTO (cod_evento);
alter table costo_evento add constraint TELEVISORA_cod_televisora foreign key (cod_televisora) references TELEVISORA(cod_televisora);

--inciso 2
--En la tabla “Evento” se decidió que la fecha y hora se trabajaría en una sola columna
alter table evento drop column fecha;
alter table evento drop column hora;
alter table evento add column fecha_hora timestamp;

--inciso 3
--Todos los eventos de las olimpiadas deben ser programados del 24 de julio de 2020 a partir de las 9:00:00 
--hasta el 09 de agosto de 2020 hasta las 20:00:00.
alter table evento add constraint ck_fecha check (fecha_hora>'2020/07/24 9:00:00' and fecha_hora<'2020/08/09 20:00:00');

--inciso 4
--Se decidió que las ubicación de los eventos se registrarán previamente en una tabla y que en la tabla 
--“Evento” sólo se almacenara la llave foránea según el código del registro de la ubicación
create table SEDE(
	cod_sede integer not null,
	nombre varchar(50) not null
);
alter table sede add primary key (cod_sede);

alter table evento alter column ubicacion set data type int using ubicacion::integer;

alter table evento add constraint SEDE_cod_sede foreign key (ubicacion) references SEDE (cod_sede);

--inciso 5
--Se revisó la información de los miembros que se tienen actualmente y antes de que se ingresen a la base de 
--datos el Comité desea que a los miembros que no tengan número telefónico se le ingrese el número por Default 0
--al momento de ser cargados a la base de datos.
alter table miembro drop column telefono;
alter table miembro add column telefono integer default 0;

--inciso 6
insert into PAIS (cod_pais, nombre) values (1, 'Guatemala');
insert into PAIS (cod_pais, nombre) values (2, 'Francia');
insert into PAIS (cod_pais, nombre) values (3, 'Argentina');
insert into PAIS (cod_pais, nombre) values (4, 'Alemania');
insert into PAIS (cod_pais, nombre) values (5, 'Italia');
insert into PAIS (cod_pais, nombre) values (6, 'Brasil');
insert into PAIS (cod_pais, nombre) values (7, 'Estados Unidos');

insert into PROFESION (cod_prof, nombre) values (1, 'Médico');
insert into PROFESION (cod_prof, nombre) values (2, 'Arquitecto');
insert into PROFESION (cod_prof, nombre) values (3, 'Ingeniero');
insert into PROFESION (cod_prof, nombre) values (4, 'Secretaria');
insert into PROFESION (cod_prof, nombre) values (5, 'Auditor');

insert into MIEMBRO (cod_miembro, nombre, apellido, edad, residencia, cod_pais, cod_prof)
	values (1, 'Scott', 'Mitchell', 32, '1092 Highland Drive Manitowoc, WI 54220', 7, 3),
	(3, 'Laura', 'Cunha Silva', 55, 'Rua	Onze, 86 Uberaba-MG', 6, 5),
	(6, 'Jeuel', 'Villalpando', 31, 'Acuña de Figeroa 6106 80101 Playa Pascual', 3, 5);
insert into MIEMBRO (cod_miembro, nombre, apellido, edad, telefono, residencia, cod_pais, cod_prof)
	values (2, 'Fanette', 'Poulin', 25, 25075853, '49, boulevard Aristide Briand 76120 LE GRAND-QUEVILLY', 2, 4),
	(4, 'Juan José', 'López', 38, 36985247, '26 calle 4-10 zona 11', 1, 2),
	(5, 'Arcangela', 'Panicucci', 39, 391664921, 'Via Santa Teresa, 114 90010-Geraci Siculo PA', 5, 1);

insert into DISCIPLINA (cod_disciplina, nombre, descripcion)
	values (1, 'Atletismo', 'Saltos de longitud y triples, de altura y con pértiga o garrocha; las pruebas de lanzamiento de martillo, jabalina y disco.'),
	(2, 'Bádminton', ''),
	(3, 'Ciclismo', 'Es un arte marcial que se originó en Japón alrededor de 1880'),
	(4, 'Judo', ''),
	(5, 'Lucha', ''),
	(6, 'Tenis de Mesa', ''),
	(7, 'Boxeo', ''),
	(8, 'Natación', 'Está presente como deporte en los Juegos desde la primera edición de la era moderna, en Atenas, Grecia, en 1896, donde se disputo en aguas abiertas.'),
	(9, 'Esgrima', ''),
	(10, 'Vela', '');

insert into TIPO_MEDALLA (cod_tipo, medalla)
	values (1, 'Oro'),
	(2, 'Plata'),
	(3, 'Bronce'),
	(4, 'Platino');
	
insert into CATEGORIA (cod_categoria, categoria) values
	(1, 'Clasificatorio'),
	(2, 'Eliminatorio'),
	(3, 'Final');
	
insert into TIPO_PARTICIPACION (cod_participacion, tipo_participacion) values
	(1, 'Individual'),
	(2, 'Parejas'),
	(3, 'Equipos');
	
insert into MEDALLERO (cod_pais, cod_tipo, cantidad_medallas) values
	(5, 1, 3),
	(2, 1, 5),
	(6, 3, 4),
	(4, 4, 3),
	(7, 3, 10),
	(3, 2, 8),
	(1, 1, 2),
	(1, 4, 5),
	(5, 2, 7);
	
insert into SEDE (cod_sede, nombre) values
	(1, 'Gimnasio Metropolitano de Tokio'),
	(2, 'Jardín del Palacio Imperial de Tokio'),
	(3, 'Gimnasio Nacional Yoyogi'),
	(4, 'Nippon Budokan'),
	(5, 'Estadio Olímpico');
	
insert into EVENTO (cod_evento, fecha_hora, ubicacion, cod_disciplina, cod_participacion, cod_categoria) values
	(1, '2020/07/24 11:00:00', 3, 2, 2, 1),
	(2, '2020/07/26 10:30:00', 1, 6, 1, 3),
	(3, '2020/07/30 18:45:00', 5, 7, 1, 2),
	(4, '2020/08/01 12:15:00', 2, 1, 1, 1),
	(5, '2020/08/08 19:35:00', 4, 10, 3, 1);

--inciso 7
alter table pais drop constraint pais_nombre_key;

alter table tipo_medalla drop constraint tipo_medalla_medalla_key;

alter table departamento drop constraint departamento_nombre_key;

SELECT *
FROM information_schema.constraint_table_usage
WHERE table_name = 'departamento'

--inciso 8
alter table atleta drop column cod_disciplina;

create table DISCIPLINA_ATLETA(
	cod_atleta integer not null,
	cod_disciplina integer not null
);
alter table disciplina_atleta add primary key (cod_atleta, cod_disciplina);
alter table disciplina_atleta add constraint ATLETA_cod_atleta foreign key (cod_atleta) references ATLETA (cod_atleta);
alter table disciplina_atleta add constraint DISCIPLINA_cod_disciplina foreign key (cod_disciplina) references DISCIPLINA(cod_disciplina);

--inciso 9
alter table costo_evento alter column tarifa set data type decimal(12, 2);

--inciso 10
delete from medallero
	where cod_tipo = 4;
delete from tipo_medalla
	where cod_tipo = 4;
	
--inciso 11
drop table costo_evento;
drop table televisora;

--inciso 12
select * from evento;
delete from evento;
delete from disciplina;
select * from disciplina;

--inciso 13
update miembro set telefono='55464601'
  where nombre='Laura' and apellido='Cunha Silva';
update miembro set telefono='91514243'
  where nombre='Jeuel' and apellido='Villalpando';
update miembro set telefono='920686670'
  where nombre='Scott' and apellido='Mitchell';  

--inciso 14
alter table atleta add column fotografia bytea;

--inciso 15
alter table atleta add constraint ck_edad check (edad>0 and edad<25);
