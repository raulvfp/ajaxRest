*
*|--------------------------------------------------------------------------
*| ajaxRest
*|--------------------------------------------------------------------------
*|
*| Archivo principal del sistema
*| Author......: Raúl Jrz (raul.jrz@gmail.com)
*| Created.....: 19.05.2018 17:19
*| Purpose.....: realizar conexiones ajax usando MSXML2.ServerXMLHTTP
*|
*| Revisions...: v1.00
*|
*/
*-----------------------------------------------------------------------------------*
DEFINE CLASS ajaxRest AS CUSTOM
*
*-----------------------------------------------------------------------------------*
	bRelanzarThrow = .T. &&Relanza la excepcion al nivel superior, usado por catchException

	PROTECTED loHeader, loParameter
	loHeader       = ''  &&Objeto que contiene las cabeceras de la conexion
	loParameter    = ''  &&Objeto que contiene los parametros que se pasara a la url

	urlRequest     = ''
	method         = ''  &&Posibles valores: POST,GET,PUT,DELETE,HEAD,CONNECT,OPTIONS,TRACE,PATCH
	Body           = ''
	pathDownload   = ''  &&Path en donde se descargaran los archivos
	pathUpload     = ''  &&Path en donde recide los archivos a subir
	pathLog        = ''  &&Path en donde se guarda los log, si es que esta activo el log.
	nameLog        = 'ajaxRest.log' &&Es el log de los procesos
	isVerbose      = .F. &&Si hay eco o no en la pantalla de las acciones.
	isLogger       = .F. &&indica si lleva un log con los registros de los sucesos.


	*-- repuesta del servidor
	PROTECTED responseValue
	readystate     = ''
	responsebody   = ''
	responseValue  = ''
	status         = 0
	ResponseHeader = ''
	ResponseCnType = ''  &&Es el valor de Content-Type por el webservice, que identifica si es un archivo o no
	ResponseCnLeng = ''  &&Si es una archivo, aqui viene la longitud en byte. Ojo, es un nro en CARACTER

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
		*THIS.TypeNotArchive = 'application/json,text/plain,application/octet-stream'

		TEXT TO loTiposdeMime NOSHOW 
		*-- Tipos de Content-Type --*
		*-- https://developer.mozilla.org/es/docs/Web/HTTP/Basics_of_HTTP/MIME_types
Type	Description	Example of typical                                                  subtypes
----    ------------------------------                                                  --------
text	Represents any document that contains text and is theoretically human readable	text/plain, text/html, 
                                                                                        text/css,   text/javascript
image	Represents any kind of images.                                                  image/gif,  image/png, 
                                                                                        image/jpeg, image/bmp
audio	Represents any kind of audio files	                                            audio/midi, audio/mpeg,
                                                                                        audio/webm, audio/ogg
video	Represents any kind of video files	                                            video/webm, video/ogg
application	Represents any kind of binary data.	                                        application/octet-stream, 
                                                                                        application/pkcs12, 
                                                                                        application/vnd.mspowerpoint
		*--
		Extensión	Tipo de documento                           Tipo de MIME
		---------   -----------------                           ------------
			.aac	AAC audio file	                            audio/aac
			.abw	AbiWord document                            application/x-abiword
			.arc	Archive document (multiple files embedded)	application/octet-stream
			.avi	AVI: Audio Video Interleave	                video/x-msvideo
			.azw	Amazon Kindle eBook format	                application/vnd.amazon.ebook
			.bin	Any kind of binary data	                    application/octet-stream
			.bz	    BZip archive	                            application/x-bzip
			.bz2	BZip2 archive	                            application/x-bzip2
			.csh	C-Shell script	                            application/x-csh
			.css	Cascading Style Sheets (CSS)	            text/css
			.csv	Comma-separated values (CSV)	            text/csv
			.doc	Microsoft Word	                            application/msword
			.epub	Electronic publication (EPUB)	            application/epub+zip
			.gif	Graphics Interchange Format (GIF)	        image/gif
			.htm    HyperText Markup Language (HTML)	        text/html
			.html	HyperText Markup Language (HTML)	        text/html
			.ico	Icon format	                                image/x-icon
			.ics	iCalendar format	                        text/calendar
			.jar	Java Archive (JAR)	                        application/java-archive
			.jpeg   JPEG images	                                image/jpeg
			.jpg	JPEG images	                                image/jpeg
			.js	    JavaScript (ECMAScript)	                    application/javascript
			.json	JSON format	                                application/json
			.mid	Musical Instrument Digital Interface (MIDI)	audio/midi
			.mpeg	MPEG Video	                                video/mpeg
			.mpkg	Apple Installer Package	                    application/vnd.apple.installer+xml
			.odp	OpenDocuemnt presentation document	        application/vnd.oasis.opendocument.presentation
			.ods	OpenDocuemnt spreadsheet document	        application/vnd.oasis.opendocument.spreadsheet
			.odt	OpenDocument text document	                application/vnd.oasis.opendocument.text
			.oga	OGG audio	                                audio/ogg
			.ogv	OGG video	                                video/ogg
			.ogx	OGG	                                        application/ogg
			.pdf	Adobe Portable Document Format (PDF)	    application/pdf
			.ppt	Microsoft PowerPoint	                    application/vnd.ms-powerpoint
			.rar	RAR archive	                                application/x-rar-compressed
			.rtf	Rich Text Format (RTF)	                    application/rtf
			.sh	    Bourne shell script	                        application/x-sh
			.svg	Scalable Vector Graphics (SVG)	            image/svg+xml
			.swf	Adobe Flash document	                    application/x-shockwave-flash
			.tar	Tape Archive (TAR)   	                    application/x-tar
			.tif	Tagged Image File Format (TIFF)	            image/tiff
			.ttf	TrueType Font	                            font/ttf
			.vsd	Microsft Visio	                            application/vnd.visio
			.wav	Waveform Audio Format	                    audio/x-wav
			.weba	WEBM audio	                                audio/webm
			.webm	WEBM video	                                video/webm
			.webp	WEBP image	                                image/webp
			.woff	Web Open Font Format (WOFF)	                font/woff
			.woff2	Web Open Font Format (WOFF)	                font/woff2
			.xhtml	XHTML	                                    application/xhtml+xml
			.xls	Microsoft Excel	                            application/vnd.ms-excel
			.xml	XML	                                        application/xml
			.xul	XUL	                                        application/vnd.mozilla.xul+xml
			.zip	ZIP archive	                                application/zip
			.3gp	3GPP audio/video container	                video/3gpp
			.3gp	3GPP audio container                        audio/3gpp
			.3g2	3GPP2 audio/video container                 video/3gpp2
			.3g2	3GPP2 audio container                       audio/3gpp2
			.7z	    7-zip archive	                            application/x-7z-compressed
		ENDTEXT
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION method_Assign(teValue)
	* Este metodo ASSIGN me permite validar lo que el verbo HTTP que se usara 
	* para comunicarse con el servidor REST
	*----------------------------------------------------------------------------*
		LOCAL lcListMethod, lcMessage
		lcMessage = 'Error, el verbo no es el correcto'
		TRY
			lcListMethod = 'POST,GET,PUT,DELETE,HEAD,CONNECT,OPTIONS,TRACE,PATCH'
			IF !(teValue $ lcListMethod) THEN
				IF THIS.isVerbose THEN
					WAIT WINDOWS lcMessage
				ENDIF
				THROW lcMessage
			ENDIF
			THIS.method = teValue
		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		ENDTRY
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION urlRequest_Assign(teValue)
	* Este metodo ASSIGN me permite validar la URL ingresada
	*----------------------------------------------------------------------------*
		LOCAL lcListMethod
		TRY
			THIS.urlRequest = STRTRAN(teValue,'\/',"/")
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
	FUNCTION addParameter(tcKey, tcValue)
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
	FUNCTION createConnection
	* Test with all XML Versions
	* Can also apply the info from http://support.microsoft.com/kb/278674/en-us
	* to determine what version of MSXML is installed in the machine
	*----------------------------------------------------------------------------*
		LOCAL loConnection
		THIS.initResponse()
		TRY
			loConnection = CREATEOBJECT("MSXML2.ServerXMLHTTP.4.0") 
		CATCH
			TRY
				loConnection = CREATEOBJECT("MSXML2.ServerXMLHTTP.3.0") 
			CATCH
				TRY
					loConnection = CREATEOBJECT("MSXML2.ServerXMLHTTP.5.0") 
				CATCH
					TRY
						loConnection = CREATEOBJECT("MSXML2.ServerXMLHTTP.6.0") 
					CATCH
						oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
					ENDTRY
				ENDTRY
			ENDTRY
		ENDTRY	
		RETURN loConnection
	ENDFUNC

	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION initResponse
	* Inicializo todas las propiedades que maneja el response 
	*----------------------------------------------------------------------------*
		THIS.readystate     = ''
		THIS.responsebody   = ''
		THIS.responseValue  = ''
		THIS.status         = 0
		THIS.ResponseHeader = ''
		THIS.ResponseCnType = ''  &&Es el valor de Content-Type por el webservice, que identifica si es un archivo o no
		THIS.ResponseCnLeng = ''  &&Si es una archivo, aqui viene la longitud en byte. Ojo, es un nro en CARACTER
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION SEND
	* Realiza la conexion con el servidor.
	*----------------------------------------------------------------------------*
		LOCAL loXMLHTTP, lcMessage,;
			lcKey, lnCnt, lnInd
		lcMessage = ''

		THIS.logger('=====[request]=====')
		loXMLHTTP = THIS.createConnection()
		TRY
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
				THIS.logger('Parameters: '+lcParameter)

				*--- Abro la conexion, enviando los parametros ---*
				.OPEN(THIS.method, THIS.urlRequest+lcParameter, .F.)
				*--- Cargo el Header de la peticion --- *
				lnCnt = AMEMBERS(laProperties, THIS.loHeader, 0)
				FOR lnInd = 1 TO lnCnt
					lcKey  = laProperties[lnInd]
					.setRequestHeader(STRCONV(lcKey, 16), THIS.loHeader.&lcKey)
					THIS.logger('Header: '+STRCONV(lcKey, 16)+" "+THIS.loHeader.&lcKey)
				ENDFOR
				
				THIS.logger('Body: '+CHR(13)+CHR(10)+THIS.Body)
				.SEND(THIS.Body)

				*--- Determino que tipo de repuesta recibi ---*
				THIS.ResponseHeader = .getAllResponseHeaders
				THIS.ResponseCnType = THIS.getOneHeader('Content-Type:') 
				THIS.ResponseCnLeng = THIS.getOneHeader('Content-Length:') &&Si es distinto de "" es un archivo.

				TRY 
					IF VAL(THIS.ResponseCnLeng)=0 OR;
						LEN(.ResponseText)=VAL(THIS.ResponseCnLeng)
						lcMessage = .ResponseText
					ELSE
						lcMessage = .ResponseBody
					ENDIF
				CATCH TO loExAux
					lcMessage = .ResponseBody
				ENDTRY

				THIS.logger('=====[response]=====')
				THIS.logger(THIS.ResponseHeader)
				THIS.logger(lcMessage)
			ENDWITH

		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		FINALLY
			THIS.readyState   =loXMLHTTP.readyState
			THIS.responseBody =loXMLHTTP.responseBody
			THIS.responseValue=lcMessage
			THIS.status       =loXMLHTTP.status
			THIS.statusText   =loXMLHTTP.statusText

			IF VARTYPE(loEx)='O' THEN  &&Si se produjo una excepcion, busco mostrar el status en el nivel superior
				STRTOFILE(loXMLHTTP.getAllResponseHeaders, 'loghttp.log', 1)
				loEx.userValue = '{"status": ' + TRANSFORM(THIS.status) ;
								 +', "statusText": "'+THIS.statusText+'"';
								 +'}'
			ENDIF

			loXMLHTTP = NULL
		ENDTRY
		RETURN lcMessage
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION saveFile(tcNameFile)
	* Si lo que se recibe es un archivo, lo guarda en el THIS.pathDownload
	*----------------------------------------------------------------------------*
		LOCAL lnReturn, lcNameFile
		lnReturn = -1
		TRY
			*-- Verifico si existe el directorio, de lo contrario lo creo.
			THIS.pathDownload = THIS.isFolderExist(THIS.pathDownload)

			*-- Verifico el nombre del archivo, si no tengo genero uno con extension tmp.
			lcNameFile = IIF(PCOUNT()=1, ALLTRIM(tcNameFile), SYS(3)+'.tmp')
			lnReturn   = STRTOFILE(THIS.getResponse(), ADDBS(THIS.pathDownload)+lcNameFile, .F.)
		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		ENDTRY
		RETURN lnReturn
	ENDFUNC
	
	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION isFolderExist(tcFolder)
	* Verifica que exista la carpeta.
	*----------------------------------------------------------------------------*
		LOCAL lcFolder
		TRY
			lcFolder = ALLTRIM(tcFolder)
			IF !EMPTY(lcFolder) THEN
				IF RIGHT(lcFolder,1) = '\' THEN
					lcFolder = SUBSTR(lcFolder,1,LEN(lcFolder)-1)
				ENDIF

				IF !DIRECTORY(lcFolder) THEN
					MKDIR (lcFolder)
				ENDIF
			ENDIF
		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		ENDTRY
		RETURN lcFolder
	ENDFUNC

	*----------------------------------------------------------------------------*
	PROTECTED FUNCTION logger(tcMessageLog)
	* Guarda una log del proceso en un archivo.
	*----------------------------------------------------------------------------*
		TRY
			IF THIS.isLogger THEN
				THIS.pathLog = THIS.isFolderExist(THIS.pathLog)
				THIS.nameLog = IIF(EMPTY(THIS.nameLog),'ajaxrest.log',ALLTRIM(THIS.nameLog))
				STRTOFILE(tcMessageLog+CHR(13)+CHR(10), ADDBS(THIS.pathLog)+THIS.nameLog,.T.)
			ENDIF

		CATCH TO loEx
			oTmp = CREATEOBJECT('catchException',THIS.bRelanzarThrow)
		ENDTRY
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION getResponse()
	* Devuelve el response de la comunicacion.
	*----------------------------------------------------------------------------*
		RETURN THIS.responseValue
	ENDFUNC

	*----------------------------------------------------------------------------*
	FUNCTION getOneHeader(tcFindHeader)
	* Busca una de las propiedades recibidas por getAllResponseHeaders()
	*----------------------------------------------------------------------------*
		LOCAL lcOneHeader, lcAux1
		lcOneHeader = ''
		lnPos = AT(tcFindHeader,THIS.ResponseHeader)	&&Si es 0, no existe en la recepcion
		IF lnPos>0 THEN
			lcAux1 = ALLTRIM(SUBSTR(THIS.ResponseHeader,lnPos+LEN(tcFindHeader)))
			lcOneHeader = SUBSTR(lcAux1,1,AT(CHR(13),lcAux1)-1)
		ENDIF
		RETURN lcOneHeader
	ENDFUNC

ENDDEFINE