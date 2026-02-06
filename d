El problema no estaba en el timeout del script principal.
El tiempo solo se aumentó para evitar cortes prematuros en consultas remotas, pero eso no era la causa del resultado vacío.

El problema real estaba en una validación lógica interna, donde el script solo procesaba instancias con versiones antiguas de SQL Server (2000, 2005, 2008).

En el entorno actual no existen instancias con esas versiones, por lo que ninguna cumplía la condición y el arreglo de instancias quedaba vacío.
Como consecuencia, el bloque final que genera los archivos nunca se ejecutaba, aunque sí existían alertas en SQLdm.

Al quitar esa validación por versión (manteniendo la consulta de versión), el flujo pudo continuar normalmente y se generaron los logs con información real.
