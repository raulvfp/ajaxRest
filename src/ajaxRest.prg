*
*|--------------------------------------------------------------------------
*| ajaxRest
*|--------------------------------------------------------------------------
*|
*| Archivo principal del sistema
*| Author......: Raúl Jrz (raul.jrz@gmail.com)
*| Created.....: 19.05.2018 17:19
*| Purpose.....: realizar conexiones ajax respetando los verbos
*|
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS ajaxRest AS CUSTOM
*
*-----------------------------------------------------------------------------------*
	PROTECTED loHeader, loParameter
	loHeader       = ''
	bRelanzarThrow = .T. &&Relanza la excepcion al nivel superior
	urlRequest     = ''
	method         = ''  &&Posibles valores: POST,GET,PUT,DELETE,HEAD,CONNECT,OPTIONS,TRACE,PATCH
	Body           = ''

	*-- repuesta del servidor
	readystate     = ''
	responsebody   = ''
	responseText   = ''
	status         = 0
*--     Estados
*--     100-Continue              101-Switching protocols    200-OK
*--     201-Created               202-Accepted               203-Non-Authoritative Information
*--     204-No Content            205-Reset Content          206-Partial Content
*--     300-Multiple Choices      301-Moved Permanently      302-Found
*--     303-See Other             304-Not Modified           305-Use Proxy
*--     307-Temporary Redirect    400-Bad Request            401-Unauthorized
*--     402-Payment Required      403-Forbidden              404-Not Found
*--     405-Method Not Allowed    406-Not Acceptable         407-Proxy Authentication Required
*--     408-Request Timeout       409-Conflict               410-Gone
*--     411-Length Required       412-Precondition Failed    413-Request Entity Too Large
*--     414-Request-URI Too Long  415-Unsupported Media Type 416-Requested Range Not Suitable
*--     417-Expectation Failed    500-Internal Server Error  501-Not Implemented
*--     502-Bad Gateway           503-Service Unavailable    504-Gateway Timeout
*--     505-HTTP Version Not Supported
	statustext     = ''

	*----------------------------------------------------------------------------*
	FUNCTION INIT
	* Inicio el objeto creando dos Objetos EMTPY uno para los HEADER y otro para los
	* PARAMETERS.
	* Ademas defino Headers por default, pero que luego el programador puede cambiar
	*----------------------------------------------------------------------------*
		THIS.loParameter= CREATEOBJECT('empty')
		THIS.loHeader   = CREATEOBJECT('empty')

		*-- Valores por default --*
		THIS.addHeader("Content-Type" ,'application/x-www-form-urlencoded')
		THIS.addHeader("HttpVersion"  ,'1.1')
		THIS.addHeader("UserAgent"    ,'FoxPro/9.0')
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION method_Assign(teValue)
	* Este metodo ASSIGN me permite validar lo que el verbo HTTP que se usara 
	* para comunicarse con el servidor REST
	*----------------------------------------------------------------------------*
		LOCAL lcListMethod
		TRY
			lcListMethod = 'POST,GET,PUT,DELETE,HEAD,CONNECT,OPTIONS,TRACE,PATCH'
			IF !(teValue $ lcListMethod) THEN
				THROW 'Error, el verbo no es el correcto'
			ENDIF
			THIS.method = teValue
		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		ENDTRY
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION addHeader(tcKey, tcValue)
	* Agrega un elemento al header
	*----------------------------------------------------------------------------*
		LOCAL lcKey
		TRY
			&& lo combierto a Hexadecimal para evitar conflictos con caracteres 
			&& en la definicion de propiedades del objeto VFP.
			lcKey = '_'+STRCONV(tcKey,15)             
			IF PEMSTATUS(THIS.loHeader, lcKey, 5) THEN
				THIS.loHeader.&lcKey = tcValue
			ELSE
				ADDPROPERTY(THIS.loHeader, lcKey, tcValue)
			ENDIF
		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		ENDTRY
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION addParameters(tcKey, tcValue)
	* Agrega un elemento a los parametros
	*----------------------------------------------------------------------------*
		LOCAL lcKey
		TRY
			&& lo combierto a Hexadecimal para evitar conflictos con caracteres 
			&& en la definicion de propiedades del objeto VFP.
			lcKey = '_'+STRCONV(tcKey,15)
			IF PEMSTATUS(THIS.loHeader, lcKey, 5) THEN
				THIS.loParameter.&lcKey = tcValue
			ELSE
				ADDPROPERTY(THIS.loParameter, lcKey, tcValue)
			ENDIF
		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		ENDTRY
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION SEND
	* Realiza la conexion con el servidor.
	*----------------------------------------------------------------------------*
		LOCAL loXMLHTTP AS "MSXML2.XMLHTTP", lcMessage,;
			lcKey, lnCnt, lnInd
		lcMessage = ''
		TRY
			loXMLHTTP = CREATEOBJECT("MSXML2.XMLHTTP")
			WITH loXMLHTTP AS MSXML2.XMLHTT
				*--- Cargo los Parametros de la peticion --- *
				lnCnt = AMEMBERS(laProperties, THIS.loParameter, 0)
				lcParameter=''
				FOR lnInd = 1 TO lnCnt
					lcKey  = laProperties[lnInd]
					lcParameter = lcParameter + STRCONV(lcKey, 16) +'='+THIS.loParameter.&lcKey + "&"
				ENDFOR
				lcParameter = SUBSTR(lcParameter,1,LEN(lcParameter)-1)  &&le quito el ultomo "&"
				IF !EMPTY(lcParameter) THEN
					lcParameter = "?"+lcParameter                       &&Le agrego antes de los parametros el '?' 
				ENDIF

				*--- Abro la conexion ---*
				.OPEN(THIS.method, THIS.urlRequest+lcParameter, .F.)
				*--- Cargo el Header de la peticion --- *
				lnCnt = AMEMBERS(laProperties, THIS.loHeader, 0)
				FOR lnInd = 1 TO lnCnt
					lcKey  = laProperties[lnInd]
					.setRequestHeader(STRCONV(lcKey, 16), THIS.loHeader.&lcKey)
				ENDFOR
				
				.SEND(THIS.Body)
				
				lcMessage = .responseText &&obtengo la repuesta
			ENDWITH

		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		FINALLY
			THIS.readystate  =loXMLHTTP.readystate
			THIS.responsebody=loXMLHTTP.responseBody
			THIS.responseText=loXMLHTTP.responseText
			THIS.status      =loXMLHTTP.status
			THIS.statustext  =loXMLHTTP.statustext
			IF VARTYPE(loEx)='O' THEN
				loEx.userValue = '{"status": ' + TRANSFORM(THIS.status) ;
								 +', "statustext": "'+THIS.statustext+'"';
								 +'}'
			ENDIF								
			loXMLHTTP = NULL
		ENDTRY
		RETURN lcMessage
	ENDFUNC

ENDDEFINE