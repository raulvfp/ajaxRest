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
**None! There is no dependency!**


## Installation
git clone https://github.com/raulvfp/ajaxRest.git ajaxRest


## Usage
Metodo: 
- get(lcURL) 
	+ Parameters: La dirección web de la consulta.

## Example:
```
    lcURLWebService= "https://www.purgomalum.com/service/json?text=Prueba%20vfp9"

	oHTTP = CREATEOBJECT('geturl')
	lcRequest = oHTTP.get(lcURLWebService)   
```
