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
	method         = ''
	Body           = ''

	*----------------------------------------------------------------------------*
	FUNCTION INIT
	*
	*----------------------------------------------------------------------------*
		THIS.loParameter= CREATEOBJECT('empty')
		THIS.loHeader   = CREATEOBJECT('empty')

		*-- Valores por default --*
		THIS.addHeader("Content-Type" ,'application/x-www-form-urlencoded')
		THIS.addHeader("authorization",'')
		THIS.addHeader("HttpVersion"  ,'1.1')
		THIS.addHeader("UserAgent"    ,'FoxPro/9.0')
	ENDFUNC
	
	*----------------------------------------------------------------------------*
	FUNCTION authorization_Assign(teValue)
	*
	*----------------------------------------------------------------------------*
		THIS.addHeader("authorization",teValue)
		THIS.authorization = teValue
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION method_Assign(teValue)
	*
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
			lcKey = '_'+STRCONV(tcKey,15)
			IF PEMSTATUS(THIS.loHeader, lcKey, 5) THEN
				THIS.loHeader.&lcKey = tcValue
			ELSE
				ADDPROPERTY(THIS.loHeader, lcKey, tcValue)
			ENDIF
		CATCH TO loEx
			*			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
			THROW
		ENDTRY
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION addParameters(tcKey, tcValue)
	* Agrega un elemento a los parametros
	*----------------------------------------------------------------------------*
		LOCAL lcKey
		TRY
			lcKey = '_'+STRCONV(tcKey,15)
			IF PEMSTATUS(THIS.loHeader, lcKey, 5) THEN
				THIS.loParameter.&lcKey = tcValue
			ELSE
				ADDPROPERTY(THIS.loParameter, lcKey, tcValue)
			ENDIF
		CATCH TO loEx
			*			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
			THROW
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
				lcParameter = SUBSTR(lcParameter,1,LEN(lcParameter)-1)
				IF !EMPTY(lcParameter) THEN
					lcParameter = "?"+lcParameter
				ENDIF

				.OPEN(THIS.method, THIS.urlRequest+lcParameter, .F.)

				*--- Cargo el Header de la peticion --- *
				lnCnt = AMEMBERS(laProperties, THIS.loHeader, 0)
				FOR lnInd = 1 TO lnCnt
					lcKey  = laProperties[lnInd]
					.setRequestHeader(STRCONV(lcKey, 16), THIS.loHeader.&lcKey)
				ENDFOR
				
				.SEND(THIS.Body)
				
				lcMessage = .responseText
			ENDWITH

		CATCH TO loEx
			*			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
			THROW
		ENDTRY
		RETURN lcMessage
	ENDFUNC

ENDDEFINE