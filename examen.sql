/**************** PART 1 ****************/
CREATE DATABASE examen_multiples_tablas;

\c examen_multiples_tablas
/*
id sera una serial y primary key, serial determina que los datos ingresado iran de numeros sucecivos crecientes,
mientras que primary key nos dice que los registros ingresados no se
repetiran nunca y tampoco podran ser de tipo null
name sera de tipo varchar con un limite de 255 y año de tipo integer sin limitante tal y como nos lo
presenta el modelo fisico en la imagen
*/
CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    anno INTEGER
);
/*
en la siguinte tabla tag tambien tendremos un id serial primary key
y los tag seran de tipo varchar con un limite de 32 siguendo los requerimientos de dichas tablas
*/
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    tag VARCHAR(32)
);
/*
ahora procederemos con la tabla que relacionara estas 2  esta sera movies_tags haciendo referencia
a las tablas que conectara
esta tabla poseera tambien un id serial primary key tendra un movie_id y un tag_id ambos integer
y al mismo tiempo ambos sera foreign key estas foreign key son los registos relacionados asociados
a la primary key de las tablas que  hacen referencia movie_id asociada al id de la tabla movies
y tag_id asociada al id de la tabla tags
*/
CREATE TABLE movies_tags (
    id SERIAL PRIMARY KEY,
    movie_id INTEGER,
    tag_id INTEGER,
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
);
/*
a continuacion realizaremos la insercion de registros en las tablas que hemos creado
en las tablas movies y tags realizaremos la insercion de registos de manera normal
*/
INSERT INTO movies (name, anno)
VALUES ('princess mononoke',1997),
       ('akira',1988),
       ('perfect blue', 1997),
       ('ghost in the shell', 1995),
       ('paprika', 2006);

INSERT INTO tags (tag)
VALUES ('adventure'),
       ('animation'),
       ('action'),
       ('crime'),
       ('drama');

/*
ahora la tabla movies_tags la insercion sera de manera mas dinamica para evitar inconcistencias en los datos
es por ello que la insercion sera realizada con consultas dentro esto en caso de que algun dato no exista
nos de un error y al mismo tiempo si los registos fueran demasiados no debemos buscar el id de las otras tablas
haciendo el proceso mas dinamico
*/
INSERT INTO movies_tags (movie_id, tag_id)
VALUES ((SELECT id FROM movies WHERE name = 'princess mononoke'),(SELECT id FROM tags WHERE tag = 'adventure')),
       ((SELECT id FROM movies WHERE name = 'princess mononoke'),(SELECT id FROM tags WHERE tag = 'animation')),
       ((SELECT id FROM movies WHERE name = 'princess mononoke'),(SELECT id FROM tags WHERE tag = 'action')),
       ((SELECT id FROM movies WHERE name = 'ghost in the shell'),(SELECT id FROM tags WHERE tag = 'animation')),
       ((SELECT id FROM movies WHERE name = 'ghost in the shell'),(SELECT id FROM tags WHERE tag = 'action'));

/*
ahora para demostrar que estas tablas funcionan de manera correcta contaremos la cantidad de tags de cada pelicula
y mostraremos 0 en caso de que no posean tags asociados para esto realizaremos un selec al id y name
de la tabla movies y un count a tag id de la tabla movies_tags , estos datos los traeremos de la tabla movie y movies_tags
uniendolos con un left join con la condicion de que el id de la pelicula debe ser igual al id encontrado en la tabla
que relaciona ambas tablas principales luego los agruparemos por el id de cada pelicula y su nombre y para
mostrar de manera mas ordenada usaremos un order by el id de la pelucila con un asc

*/

SELECT movies.id, movies.name, COUNT(movies_tags.tag_id) FROM movies
    LEFT JOIN movies_tags on movies.id = movies_tags.movie_id
            GROUP BY movies.id, movies.name ORDER BY movies.id ASC;

/**************** PART 2 ****************/

/*
para la segunda parte utilizaremos este modelo (imagen) al igual que en ejercicio anterior crearemos las tablas
con sus respectivas primary key y/o foreign key segun corresponda
estas tablas seran questions, users y answer
*/
CREATE TABLE questions (
    id SERIAL PRIMARY KEY,
    question VARCHAR(255),
    correct_answer VARCHAR
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    age INTEGER
);

CREATE TABLE answers (
    id SERIAL PRIMARY KEY,
    answer VARCHAR(255),
    user_id INTEGER,
    question_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);
/*
insertaremos los datos en estas tablas al igual que en ejercio mostrado al comienzo
*/
INSERT INTO questions (question, correct_answer)
VALUES ('1+1=','2'),
       ('2+2=','4'),
       ('3+3=','6'),
       ('4+4=','8'),
       ('5+5=','10');

INSERT INTO users (name,age)
VALUES ('paula',30),
       ('felipe',33),
       ('victoria',32),
       ('diego',26),
       ('valentina',27);

INSERT INTO answers (answer, user_id, question_id)
VALUES ('2',(SELECT id FROM users WHERE name = 'paula' ), (SELECT id FROM questions WHERE question = '1+1=')),
       ('4',(SELECT id FROM users WHERE name = 'paula' ), (SELECT id FROM questions WHERE question = '2+2=')),
       ('2',(SELECT id FROM users WHERE name = 'diego' ), (SELECT id FROM questions WHERE question = '1+1=')),
       ('9',(SELECT id FROM users WHERE name = 'felipe' ), (SELECT id FROM questions WHERE question = '5+5=')),
       ('9',(SELECT id FROM users WHERE name = 'valentina' ), (SELECT id FROM questions WHERE question = '4+4='));

/* ahora para mostrar el como estas tablas se relacionan  realizaremos una serie de consultas y al final modificaremos
ciertos datos para demostrar como la confeccion de las tablas puede afectar a otras
a continuacion mostraremos la cantidad de respuesta correctas totales por usuarios independiente de la pregunta
para esto seleccionaremos el name y contaremos count para contar de la tabla questions el id esto utilizado la tabla users
uniendola con un left join a la tabla answers en donde el id del usuario en la tabla users sea igual
al user_id en la tabla answers y al mismo tiempo uniremos esto con otro left join a la tabla questions en donde
el question_id de la tabla answers sea igual al id de la tabla questions y que answer de la tabla answers sea igual
a correct_answer de la tabla questions agruparemos los datos por el name de la tabla users

*/

SELECT users.name, COUNT(questions.id)
FROM users
    LEFT JOIN answers ON users.id = answers.user_id
LEFT JOIN questions ON answers.question_id = questions.id AND answers.answer = questions.correct_answer
GROUP BY users.name;

/*
ahora contaremos cuantos usuarios tuvieron la respuesta correcta pero por cada pregunta de la tabla preguntas
para esto realizaremos un SELECT a question de la tabla questions y un COUNT a answer de la tabla answers obtendremos
estos datos relacionado a la tabla questions con la tabla answers por medio de un LEFT JOIN en donde question_id
de la tabla answers sea igual al id de la tabla questions y al mismo tiempo que answers de la tabla answers sea igual
a correct_answer de la tabla questions agruparemos estos registros por id y questions de la tabla questions y ordenaremos
por id
 */
SELECT questions.question, COUNT(answers.answer)
FROM questions
        LEFT JOIN answers ON answers.question_id = questions.id AND answers.answer = questions.correct_answer
GROUP BY questions.id, questions.question ORDER BY questions.id ASC;

/*;
como dije hace un rato tambien podemos modificar estas tablas  para implementar ciertas funcionalidades
o en caso de querer implementar otros datos a estas tablas  es por esto si desearamos borrar datos y que no queden
datos relacionales dentro de las tablas podemos implementar ON DELETE CASCADE esto nos permitira borrar un
registo en una tabla y que se borre de todas las tablas relacionadas a esta

para ello debemos utilizar ALTER TABLE con el nombre de la tabla a la cual deseamos alterar pero si el dato a modificar
es una FOREIGN KEY primero debemos eliminar este con un DROP CONSTRAINT y al mismo tiempo un ADD CONSTRAINT
para modificar y dando las propiedades correspondiente

para verificar que esto fue implementado de manera correcta eliminaremos el id del usuario 1 en la tabla users
    Implementa borrado en cascada de las respuestas al borrar un usuario y borrar el
primer usuario para probar la implementación.
 */
ALTER TABLE answers DROP CONSTRAINT answers_user_id_fkey,
    ADD CONSTRAINT user_id
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

DELETE FROM users WHERE users.id = 1;
/*

en caso de quere modificar la tabla y añadir una condicion seria similar por ejemplo a age en la tabla users
podemos utilizar ALTER TABLE y a la age con la propiedad CHECK decir que no podremos ingresar un registo con un usuario
con edad inferior a 18

 */
ALTER TABLE users
    ADD CONSTRAINT age
CHECK ( age > 18 );
/*
y en el caso de querer agregar digamos un email a la tabla users lo podemos hacer con ALTER TABLE
ADD COLUMN email y las propiedades de esto por que sea VARCHAR CON UN LIMITE de 255 Y UNIQUE para que
los usuarios no puedar registrase con el mismo email

 */
ALTER TABLE users
ADD COLUMN email VARCHAR(255) UNIQUE;