# ajaxRest

Esta es una clase de VFP que permite la conexión a traves de HTTP, lo que habilita para consumir servicios Restful o SOAP XML.

**HTTP** define un conjunto de métodos de petición para indicar la acción que se desea realizar para un recurso determinado. Aunque estos también pueden ser sustantivos, estos métodos de solicitud a veces son llamados _HTTP verbs_. Cada uno de ellos implementan una semántica diferente, pero algunas características similares son compartidas por un grupo de ellos: ej. un request method puede ser safe, idempotent, o cacheable.

**GET**: Solicita una representación de un recurso específico. Las peticiones que usan el método GET sólo deben recuperar datos.

**HEAD**: Pide una respuesta idéntica a la de una petición GET, pero sin el cuerpo de la respuesta.

**POST**: Se utiliza para enviar una entidad a un recurso en específico, causando a menudo un cambio en el estado o efectos secundarios en el servidor.

**PUT**: Reemplaza todas las representaciones actuales del recurso de destino con la carga útil de la petición.

**DELETE**: Borra un recurso en específico.

**CONNECT**: Establece un túnel hacia el servidor identificado por el recurso.

**OPTIONS**: Es utilizado para describir las opciones de comunicación para el recurso de destino.

**TRACE**: Realiza una prueba de bucle de retorno de mensaje a lo largo de la ruta al recurso de destino.

**PATCH**: Es utilizado para aplicar modificaciones parciales a un recurso.

* support: raul.jrz@gmail.com
* url: [http://rauljrz.github.io/](http://rauljrz.github.io)


## Dependencies
https://github.com/raulvfp/catchException
    Para el control de las excepciones.

## Installation
git clone https://github.com/raulvfp/ajaxRest.git ajaxRest


## Usage
**Properties:**
- method: Valores posibles POST, GET, PUT, DELETE, etc
- urlRequest: Es la url a consultar.
- body: El cuerpo del mensaje.
- pathDownload: Path en donde se descargaran los archivos. Por defecto el CURDIR()
- pathUpload: Path en donde reciden los archivos a subir.
- isVerbose: Si hay eco o no en la pantalla de las acciones. Por defecto es .F.
- isLogger: Indica si lleva un log con los registros de los sucesos. Por defecto es .F.
- pathLog: Path en donde se guarda los log, si es que esta activo el log.
- nameLog: Es el nombre del log del proceso, si es que esta activo el log. Por defecto es 'ajaxRest.log'.

**Methods:**
- addHeader(cKey, cValue) : Agrega una clave al HEADER
	+ cKey:   Clave del HEADER 
    + cValue: Valor de la Clave del HEADER
    + Retorna: null
      ```
        .addHeader('Content-Type','text/plain')
      ```
- addParameter(cKey, cValue) : Agrega un Parametro a la peticion.
    + cKey:   Clave del Parametro 
    + cValue: Valor de la Clave del Parametro
    + Retorna: null
      ```
        .addParameter('results_per_page','1')
      ```
- send() : Envia la peticion.
    + Retorna: El Value Response de la conexion.
- getResponse() : Devuelve el Response de la conexion.
- saveFile(cNameFile) : Si lo que se recibe es un archivo, lo guarda en el folder indicado en THIS.pathDownload.
    + cNameFile: Es el nombre del archivo de salida. Si es empty, el nombre será el resultado de la funcion: SYS(3)+'.tmp'



## Example:
```
    loHTTP = CREATEOBJECT('ajaxRest')
    WITH loHTTP
        .method      = 'GET'
        .urlRequest  = 'http://thecatapi.com/api/images/get'
        .addParameter('format'          ,'src')
        .addParameter('results_per_page','1')
        .addHeader   ("Content-Type"    , 'text/plain')

        .SEND()
        IF .status=200 THEN
            .saveFile('thecat.jpg')
        ENDIF
    ENDWITH

```
