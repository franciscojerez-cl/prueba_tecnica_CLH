/*
* =============================================
*	Nombre : Francisco Jerez
*	Fecha : 29-09-2023
* =============================================
*/

use DB_lh_fjerez
go 


/*
Se solicita que se realice un modelo relacional de crédito, teniendo en consideración las definiciones anteriores, 
y asumiendo a su vez que pueden existir entidades implícitas que se necesiten para que todo el flujo crediticio pueda funcionar.
*/

/*
ALTER TABLE	ESTADO_FINANCIERO	DROP CONSTRAINT	FK_PERSONA_FINANCIERO
ALTER TABLE	ESTADO_FINANCIERO	DROP CONSTRAINT	FK_PROMOTOR_FINANCIERO
ALTER TABLE	ESTADO_FINANCIERO	DROP CONSTRAINT	FK_TIPOCREDITO_FINANCIERO
ALTER TABLE	MST_CORREO	DROP CONSTRAINT	FK_PERSONA_CORREO
ALTER TABLE	MST_TELEFONO	DROP CONSTRAINT	FK_PERSONA_TELEFONO
ALTER TABLE	MST_REGION	DROP CONSTRAINT	FK_PAIS_REGION
ALTER TABLE	MST_COMUNA	DROP CONSTRAINT	FK_REGION_COMUNA
ALTER TABLE	MST_DOMICILIO	DROP CONSTRAINT	FK_PERSONA_DOMICILIO
ALTER TABLE	MST_DOMICILIO	DROP CONSTRAINT	FK_TIPODOMICILIO_DOMICILIO
ALTER TABLE	MST_DOMICILIO	DROP CONSTRAINT	FK_COMUNA_DOMICILIO

DROP TABLE IF EXISTS [TIPO_CREDITO]
DROP TABLE IF EXISTS [ESTADO_FINANCIERO]
DROP TABLE IF EXISTS [TIPO_CREDITO]
DROP TABLE IF EXISTS [MST_CORREO]
DROP TABLE IF EXISTS [PROMOTOR]
DROP TABLE IF EXISTS [MST_TELEFONO]
DROP TABLE IF EXISTS [MST_DOMICILIO]
DROP TABLE IF EXISTS [TIPO_DOMICILIO]
DROP TABLE IF EXISTS [MST_COMUNA]
DROP TABLE IF EXISTS [MST_REGION]
DROP TABLE IF EXISTS [MST_CORREO]
DROP TABLE IF EXISTS [MST_PAIS]
DROP TABLE IF EXISTS [PERSONA]
*/

CREATE TABLE [PERSONA] (
  [id_persona] int IDENTITY(1,1) PRIMARY KEY,
  [rut] varchar(20),
  [nombre] varchar(50),
  [apellido_paterno] varchar(50),
  [apellido_materno] varchar(50),
  [fecha_nacimiento] date,
  [es_afiliado] bit,
  [es_jubilado] bit,
  [es_trabajador] bit,
  [fecha_registro] datetime
)


CREATE TABLE [PROMOTOR] (
  [id_promotor] int IDENTITY(1,1) PRIMARY KEY,
  [rut] varchar(100),
  [nombre] varchar(50),
  [apellido_paterno] varchar(50),
  [apellido_materno] varchar(50),
  [fecha_registro] datetime
)


CREATE TABLE [TIPO_CREDITO] (
  [id_tipocredito] int IDENTITY(1,1) PRIMARY KEY,
  [nombre] varchar(50)
)

CREATE TABLE [ESTADO_FINANCIERO] (
  [id_estadofinanciero] int IDENTITY(1,1) PRIMARY KEY,
  [tipocredito_id] int NOT NULL,
  [persona_id] int NOT NULL ,
  [promotor_id] int NOT NULL,
  [renta_bruta] money,
  [renta_liquida] money,
  [nivel_endeudamiento] money,
  [monto_solicitado] money,
  [fecha_ingreso] datetime,
  [es_online] bit,
  [fecha_registro] datetime ,
    CONSTRAINT FK_PERSONA_FINANCIERO FOREIGN KEY ( [persona_id] ) REFERENCES [PERSONA] ([id_persona]) ,
    CONSTRAINT FK_PROMOTOR_FINANCIERO FOREIGN KEY ( [promotor_id] ) REFERENCES [PROMOTOR] ([id_promotor]),
	CONSTRAINT FK_TIPOCREDITO_FINANCIERO FOREIGN KEY ( [tipocredito_id] ) REFERENCES [TIPO_CREDITO] ([id_tipocredito]) 
)

CREATE TABLE [MST_CORREO] (
  [id_correo] int IDENTITY(1,1) PRIMARY KEY,
  [persona_id] int,
  [Email] varchar(200),
  [permiso_contacto] bit,
  [fecha_registro] datetime,
  CONSTRAINT FK_PERSONA_CORREO FOREIGN KEY ( [persona_id] ) REFERENCES [PERSONA] ([id_persona]) 
)
 
CREATE TABLE [MST_TELEFONO] (
  [id_telefono] int IDENTITY(1,1) PRIMARY KEY,
  [persona_id] int,
  [telefono] varchar(200),
  [permiso_contacto] bit,
  [fecha_registro] datetime,
  CONSTRAINT FK_PERSONA_TELEFONO FOREIGN KEY ( [persona_id] ) REFERENCES [PERSONA] ([id_persona]) 
)


CREATE TABLE [TIPO_DOMICILIO] (
  [id_tipodomicilio] int IDENTITY(1,1) PRIMARY KEY,
  [descripcion] varchar(50)
)


CREATE TABLE [MST_PAIS] (
  [id_pais] int IDENTITY(1,1) PRIMARY KEY,
  [nombre] varchar(50)
)


CREATE TABLE [MST_REGION] (
  [id_region] int PRIMARY KEY,
  [nombre] varchar(50),
  [pais_id] int,
  CONSTRAINT FK_PAIS_REGION FOREIGN KEY ([pais_id]) REFERENCES [MST_PAIS]([id_pais])
)


CREATE TABLE [MST_COMUNA] (
  [id_comuna] int IDENTITY(1,1) PRIMARY KEY,
  [nombre] varchar(50),
  [region_id] int,
  CONSTRAINT FK_REGION_COMUNA FOREIGN KEY ([region_id]) REFERENCES [MST_REGION]([id_region])
)


CREATE TABLE [MST_DOMICILIO] (
  [id_domicilio] int IDENTITY(1,1) PRIMARY KEY,
  [persona_id] int,
  [direccion] varchar(200),
  [comuna_id] int,
  [tipodomicilio_id] int NOT NULL,
  [fecha_registro] datetime,
  CONSTRAINT FK_PERSONA_DOMICILIO FOREIGN KEY ([persona_id]) REFERENCES [PERSONA] ([id_persona]),
  CONSTRAINT FK_TIPODOMICILIO_DOMICILIO FOREIGN KEY ([tipodomicilio_id]) REFERENCES [TIPO_DOMICILIO] ([id_tipodomicilio]),
  CONSTRAINT FK_COMUNA_DOMICILIO FOREIGN KEY ([comuna_id]) REFERENCES [MST_COMUNA] ([id_comuna])
)

