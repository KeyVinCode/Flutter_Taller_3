CREATE TABLE usuarios (
    id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    password_hash  TEXT         NOT NULL,
    created_at     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE categorias (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id  BIGINT      NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    nombre      VARCHAR(80) NOT NULL,
    color_hex   CHAR(7)     NOT NULL DEFAULT '#2196F3',
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
    UNIQUE (usuario_id, nombre)
);

CREATE TABLE eventos (
    id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id    BIGINT       NOT NULL REFERENCES usuarios(id)   ON DELETE CASCADE,
    categoria_id  BIGINT       REFERENCES categorias(id)          ON DELETE SET NULL,
    titulo        VARCHAR(150) NOT NULL,
    descripcion   TEXT,
    ubicacion     VARCHAR(200),
    fecha_inicio  TIMESTAMP    NOT NULL,
    fecha_fin     TIMESTAMP    NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_fechas CHECK (fecha_fin >= fecha_inicio)
);

CREATE INDEX idx_eventos_usuario_fecha ON eventos (usuario_id, fecha_inicio);
CREATE INDEX idx_eventos_categoria     ON eventos (categoria_id);