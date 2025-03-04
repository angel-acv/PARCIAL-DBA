-- tabla de paciente


CREATE TABLE paciente (
    id SERIAL PRIMARY KEY,
    documento TEXT UNIQUE NOT NULL,
    tipo_documento TEXT NOT NULL,
    nombres TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    edad INT NOT NULL,
    genero TEXT NOT NULL,
    estado_civil TEXT,
    ocupacion TEXT,
    ciudad_nacimiento TEXT,
    pais_nacimiento TEXT,
    ciudad_residencia TEXT,
    direccion TEXT,
    eps TEXT NOT NULL,
    estrato INT
);


INSERT INTO paciente (documento, tipo_documento, nombres, apellidos, fecha_nacimiento, edad, genero, estado_civil, ocupacion, ciudad_nacimiento, pais_nacimiento, ciudad_residencia, direccion, eps, estrato) VALUES
('12345678', 'CC', 'Carlos', 'Gomez', '1990-05-12', 33, 'Masculino', 'Soltero', 'Ingeniero', 'Bogotá', 'Colombia', 'Medellín', 'Calle 10 #5-30', 'COSALUD', 3),
('87654321', 'TI', 'Laura', 'Martínez', '2008-11-25', 15, 'Femenino', 'Soltera', 'Estudiante', 'Cali', 'Colombia', 'Barranquilla', 'Carrera 20 #10-15', 'MUTUAL SER', 2),
('11223344', 'CC', 'Pedro', 'Ramírez', '1985-07-08', 38, 'Masculino', 'Casado', 'Médico', 'Cartagena', 'Colombia', 'Bogotá', 'Av. 30 #8-22', 'SURA', 4);

-- Tabla de Médicos



CREATE TABLE medico (
    id SERIAL PRIMARY KEY,
    nombres TEXT NOT NULL,
    apellidos TEXT NOT NULL,
    especialidad TEXT NOT NULL,
    titulo TEXT NOT NULL
);


INSERT INTO medico (nombres, apellidos, especialidad, titulo) VALUES
('Oscar', 'Anderson', 'Oftalmología', 'Doctorado en Medicina'),
('Luis', 'Berrio', 'Optometría', 'Máster en Optometría'),
('Ana', 'Fernández', 'Cirugía Ocular', 'Doctorado en Cirugía');


-- Tabla de Consultas


CREATE TABLE consulta (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL,
    medico_id INT NOT NULL,
    fecha DATE NOT NULL,
    valor NUMERIC(10,2),
    motivo TEXT,
    diagnostico TEXT,
    tratamiento TEXT,
    FOREIGN KEY (paciente_id) REFERENCES paciente(id) ON DELETE CASCADE,
    FOREIGN KEY (medico_id) REFERENCES medico(id) ON DELETE CASCADE
);


INSERT INTO consulta (paciente_id, medico_id, fecha, valor, motivo, diagnostico, tratamiento) VALUES
(1, 1, '2024-08-10', 50000, 'Visión borrosa', 'Miopía', 'Uso de lentes correctivos'),
(2, 2, '2024-07-15', 60000, 'Ojos secos', 'Síndrome de ojo seco', 'Gotas lubricantes'),
(3, 3, '2024-06-20', 75000, 'Dolor ocular', 'Glaucoma', 'Tratamiento con gotas');



-- Tabla de Enfermedades Oculares para pacientes es especiales


CREATE TABLE enfermedad_ocular (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);

INSERT INTO enfermedad_ocular (nombre) VALUES
('Glaucoma'),
('Catarata'),
('Astigmatismo');


-- Relación Paciente - Enfermedad Ocular



CREATE TABLE paciente_enfermedad (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL,
    enfermedad_id INT NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES paciente(id) ON DELETE CASCADE,
    FOREIGN KEY (enfermedad_id) REFERENCES enfermedad_ocular(id) ON DELETE CASCADE
);


INSERT INTO examen (nombre) VALUES
('Fondo de ojo'),
('Topografía corneal'),
('Tonometría');


-- Tabla de Exámenes



CREATE TABLE examen (
    id SERIAL PRIMARY KEY,
    nombre TEXT UNIQUE NOT NULL
);

INSERT INTO examen (nombre) VALUES
('Fondo de ojo'),
('Topografía corneal'),
('Tonometría');

-- Relación Paciente - Examen


CREATE TABLE paciente_examen (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL,
    examen_id INT NOT NULL,
    resultado TEXT,
    FOREIGN KEY (paciente_id) REFERENCES paciente(id) ON DELETE CASCADE,
    FOREIGN KEY (examen_id) REFERENCES examen(id) ON DELETE CASCADE
);


INSERT INTO paciente_examen (paciente_id, examen_id, resultado) VALUES
(1, 1, 'Normal'),
(2, 2, 'Astigmatismo detectado'),
(3, 3, 'Presión ocular elevada');


--1 

SELECT nombres, apellidos, TO_CHAR(fecha_nacimiento, 'DD-Mon-YYYY') AS fecha_nac, edad
FROM paciente
WHERE ciudad_residencia <> 'Cartagena' AND eps IN ('COSALUD', 'MUTUAL SER');


--2

SELECT eps, COUNT(id) AS total_pacientes
FROM paciente
GROUP BY eps;


-- 3. Crear una vista con el número de pacientes atendidos con enfermedades oculares
  CREATE VIEW pacientes_enfermedades AS
  SELECT e.nombre AS enfermedad, COUNT(pe.paciente_id) AS total_pacientes
  FROM paciente_enfermedad pe
  JOIN enfermedad_ocular e ON pe.enfermedad_id = e.id
  GROUP BY e.nombre;

  select * from pacientes_enfermedades;

-- 4. Información de pacientes menores de edad con enfermedades
SELECT p.id, p.nombres, p.apellidos, e.nombre AS enfermedad
FROM paciente p
JOIN paciente_enfermedad pe ON p.id = pe.paciente_id
JOIN enfermedad_ocular e ON pe.enfermedad_id = e.id
WHERE p.edad < 18;

-- 5. Vista con el número de pacientes atendidos por médicos
CREATE VIEW pacientes_por_medico AS
SELECT m.nombres || ' ' || m.apellidos AS medico, COUNT(c.id) AS total_pacientes
FROM consulta c
JOIN medico m ON c.medico_id = m.id
GROUP BY medico;

select * from pacientes_por_medico;

-- 6. Pacientes atendidos en los últimos 6 meses por médicos específicos
SELECT p.nombres, p.fecha_nacimiento, p.ciudad_residencia
FROM consulta c
JOIN paciente p ON c.paciente_id = p.id
JOIN medico m ON c.medico_id = m.id
WHERE c.fecha >= CURRENT_DATE - INTERVAL '6 months'
AND m.nombres IN ('Oscar', 'Luis') AND m.apellidos IN ('Anderson', 'Berrio');


	-- secuencia para las consultas 
		CREATE SEQUENCE consulta_seq START WITH 100 INCREMENT BY 1 MINVALUE 100 MAXVALUE 300;

-- 7. Insertar una consulta con la secuencia
INSERT INTO consulta (id, paciente_id, medico_id, fecha, valor, motivo, diagnostico, tratamiento)
VALUES (NEXTVAL('consulta_seq'), 1, 1, CURRENT_DATE, 50000, 'Dolor ocular', 'Miopía', 'Uso de lentes correctivos');







