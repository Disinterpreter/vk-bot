/*
 Navicat Premium Data Transfer

 Source Server         : cirno-pg
 Source Server Type    : PostgreSQL
 Source Server Version : 110007
 Source Host           : disi.moe:5432
 Source Catalog        : bot
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 110007
 File Encoding         : 65001

 Date: 16/04/2020 16:36:58
*/


-- ----------------------------
-- Type structure for get_roles
-- ----------------------------
DROP TYPE IF EXISTS "public"."get_roles";
CREATE TYPE "public"."get_roles" AS (
  "f1" int4,
  "f2" varchar COLLATE "pg_catalog"."default"
);

-- ----------------------------
-- Sequence structure for commands_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."commands_id_seq";
CREATE SEQUENCE "public"."commands_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for permissions_perm_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."permissions_perm_id_seq";
CREATE SEQUENCE "public"."permissions_perm_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for purpose_perp_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."purpose_perp_id_seq";
CREATE SEQUENCE "public"."purpose_perp_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for roles_role_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."roles_role_id_seq";
CREATE SEQUENCE "public"."roles_role_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for users_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."users_id_seq";
CREATE SEQUENCE "public"."users_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

-- ----------------------------
-- Table structure for commands
-- ----------------------------
DROP TABLE IF EXISTS "public"."commands";
CREATE TABLE "public"."commands" (
  "id" int8 NOT NULL DEFAULT nextval('commands_id_seq'::regclass),
  "cmd_name" varchar(255) COLLATE "pg_catalog"."default",
  "func_name" varchar(255) COLLATE "pg_catalog"."default",
  "enabled" bool,
  "public" bool DEFAULT false
)
;

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS "public"."permissions";
CREATE TABLE "public"."permissions" (
  "perm_id" int8 NOT NULL DEFAULT nextval('permissions_perm_id_seq'::regclass),
  "command_id" int8,
  "role_id" int8,
  "enabled" bool,
  "comment" varchar(255) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Table structure for purpose
-- ----------------------------
DROP TABLE IF EXISTS "public"."purpose";
CREATE TABLE "public"."purpose" (
  "perp_id" int8 NOT NULL DEFAULT nextval('purpose_perp_id_seq'::regclass),
  "user_id" int4 NOT NULL,
  "role_id" int8 NOT NULL
)
;

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS "public"."roles";
CREATE TABLE "public"."roles" (
  "role_id" int8 NOT NULL DEFAULT nextval('roles_role_id_seq'::regclass),
  "role_name" varchar(255) COLLATE "pg_catalog"."default",
  "role_description" varchar(255) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS "public"."users";
CREATE TABLE "public"."users" (
  "id" int8 NOT NULL DEFAULT nextval('users_id_seq'::regclass),
  "user_id" int8
)
;

-- ----------------------------
-- Function structure for call_cmd
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."call_cmd"("local_user_id" int8, "local_chat_id" int4, "cmd" varchar);
CREATE OR REPLACE FUNCTION "public"."call_cmd"("local_user_id" int8, "local_chat_id" int4, "cmd" varchar)
  RETURNS "pg_catalog"."varchar" AS $BODY$
DECLARE
		cmd_func_name VARCHAR(255);
		tmp_cmd_id int4;
		cmd_role_id int4;
		cmd_endres VARCHAR(255);
		cmd_pub_func VARCHAR(255);

BEGIN
		-- If arguments is exsists
		IF ( "local_user_id" IS NOT NULL AND "local_chat_id" IS NOT NULL AND "cmd" IS NOT NULL ) THEN
			-- If command is public
			SELECT func_name INTO cmd_pub_func FROM commands WHERE commands.cmd_name = "cmd" AND commands.enabled = TRUE AND commands."public" = TRUE LIMIT 1;
			IF (cmd_pub_func IS NOT NULL) THEN
					RETURN cmd_pub_func;
			END IF;
			
			-- Taking the rows if argument cmp is compare and if it enabled
			SELECT func_name, commands."id" INTO cmd_func_name, tmp_cmd_id FROM commands WHERE commands.cmd_name = "cmd" AND commands.enabled = TRUE LIMIT 1;
			-- IF cmd isn't exist
			IF (cmd_func_name IS NULL) THEN
				RETURN 'NULL';
			ELSE
			  -- Taking the roleid when usierid is compare.
				SELECT purpose.role_id AS rid INTO cmd_role_id FROM users,purpose WHERE users.user_id = "local_user_id" OR users.user_id = "local_chat_id" AND users.ID = purpose.user_id;
				IF (cmd_role_id IS NULL) THEN
					RETURN 'NULL';
				ELSE 
					-- Getting the data
					SELECT commands.func_name INTO cmd_endres FROM roles, commands, permissions WHERE roles.role_id = cmd_role_id AND func_name = cmd_func_name AND command_id = tmp_cmd_id AND permissions.enabled = TRUE;
					IF (cmd_endres IS NULL) THEN
							RETURN 'NULL';
					ELSE
							RETURN cmd_endres;
					END IF;
				END IF;
				RETURN cmd_func_name;
			END IF;
		END IF;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for get_roles
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."get_roles"("chat_id" int8);
CREATE OR REPLACE FUNCTION "public"."get_roles"("chat_id" int8)
  RETURNS SETOF "public"."get_roles" AS $BODY$
DECLARE
		-- CREATE TYPE get_roles AS (f1 integer,f2 varchar );
    resp get_roles;
BEGIN
		FOR resp IN 
		SELECT
        roles.role_id,
				roles.role_name
    FROM
        roles
    INNER JOIN purpose ON roles.role_id = purpose.role_id
    INNER JOIN users ON purpose.user_id = users."id"
    WHERE users.user_id = "chat_id"
		LOOP
			return next resp; 
		END LOOP;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."commands_id_seq"
OWNED BY "public"."commands"."id";
SELECT setval('"public"."commands_id_seq"', 7, true);
ALTER SEQUENCE "public"."permissions_perm_id_seq"
OWNED BY "public"."permissions"."perm_id";
SELECT setval('"public"."permissions_perm_id_seq"', 3, true);
ALTER SEQUENCE "public"."purpose_perp_id_seq"
OWNED BY "public"."purpose"."perp_id";
SELECT setval('"public"."purpose_perp_id_seq"', 4, true);
ALTER SEQUENCE "public"."roles_role_id_seq"
OWNED BY "public"."roles"."role_id";
SELECT setval('"public"."roles_role_id_seq"', 2, true);
ALTER SEQUENCE "public"."users_id_seq"
OWNED BY "public"."users"."id";
SELECT setval('"public"."users_id_seq"', 2, true);

-- ----------------------------
-- Primary Key structure for table commands
-- ----------------------------
ALTER TABLE "public"."commands" ADD CONSTRAINT "commands_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table permissions
-- ----------------------------
ALTER TABLE "public"."permissions" ADD CONSTRAINT "permissions_pkey" PRIMARY KEY ("perm_id");

-- ----------------------------
-- Primary Key structure for table purpose
-- ----------------------------
ALTER TABLE "public"."purpose" ADD CONSTRAINT "purpose_pkey" PRIMARY KEY ("perp_id");

-- ----------------------------
-- Primary Key structure for table roles
-- ----------------------------
ALTER TABLE "public"."roles" ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("role_id");

-- ----------------------------
-- Primary Key structure for table users
-- ----------------------------
ALTER TABLE "public"."users" ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");
