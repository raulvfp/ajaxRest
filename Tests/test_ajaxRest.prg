 */
 * @since:  1.0
 *
 * @author: Raúl Juárez <raul.jrz@gmail.com>
 * @date: 19.05.2018 18:04
 */
DEFINE CLASS test_ajaxRest as FxuTestCase OF FxuTestCase.prg
*----------------------------------------------------------------------

	#IF .f.
	LOCAL THIS AS test_ajaxRest OF test_ajaxRest.PRG
	#ENDIF
	oObject      = ''  &&Este es el objecto que va a ser evaluado
	oldPath      = ''
	oldProcedure = ''
	oldDefault   = ''

	*--------------------------------------------------------------------
	FUNCTION Setup
	* Configuración base de todos los Test de esta clase
	*--------------------------------------------------------------------
	*	SET PATH TO pathraizdelprojecto
		THIS.oldPath     =SET('PATH')
		THIS.oldProcedure=SET('PROCEDURE')
		THIS.oldDefault  =SET('DEFAULT')
		*THIS.MessageOut('Procedures: '+SET("PROCEDURE"))
		*THIS.MessageOut('Path......: '+SET("PATH"))
		*THIS.MessageOut('Default...: '+SET("DEFAULT"))
		*THIS.MessageOut('============================================================')

		SET PROCEDURE TO (ADDBS(SYS(5)+CURDIR())+'src\ajaxRest.prg') ADDITIVE
		SET PROCEDURE TO E:\Shared\Project\librery\catchException\src\catchException.prg ADDITIVE
		SET PATH TO (THIS.oldPath +";"+ADDBS(SYS(5)+CURDIR())+'src ')
		THIS.MessageOut('Procedures: '+STRTRAN(SET("PROCEDURE"),";",CHR(13)+SPACE(12)))
		THIS.MessageOut('Path......: '+STRTRAN(SET("PATH"),";",CHR(13)+SPACE(12)))
		THIS.MessageOut('Default...: '+SET("DEFAULT"))
		THIS.MessageOut('============================================================')
		THIS.MessageOut('')
		THIS.oObject = CREATEOBJECT('ajaxRest')

	ENDFUNC
	
	*---------------------------------------------------------------------
	FUNCTION testExisteObjecto()
	* Verifica la existencia del objecto...
	*---------------------------------------------------------------------
		THIS.AssertNotNull('No existe el objecto',THIS.oObject)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION TearDown
	* Restaura el estado anterior del ambiente de desarrollo
	*--------------------------------------------------------------------
		SET PATH TO      (THIS.oldPath)
		SET PROCEDURE TO (THIS.oldProcedure)
		SET DEFAULT TO   (THIS.oldDefault)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testGet_with_Header_and_Parameters
	* Note: Ejemplo de uso de metodo GET con Header & Parameters
	*--------------------------------------------------------------------
		LOCAL lcExpectedValue, lcResponseValue
		lcExpectedValue = '{"result":"Prueba vfp9"}'
		lcResponseValue = ''
		THIS.oObject.urlRequest = 'https://www.purgomalum.com/service/json'
		THIS.oObject.method     = 'GET'
		THIS.oObject.addHeader   ("Content-Type", 'application/json')
		THIS.oObject.addParameter("text", 'Prueba%20vfp9')

		lcResponseValue = THIS.oObject.SEND()
		THIS.AssertEquals(lcExpectedValue, lcResponseValue,'Error el resultado no es deseado')
		THIS.MessageOut('Valor recibido: '+lcResponseValue)
		THIS.MessageOut('Valor de Status: '+TRANSFORM(THIS.oObject.status))
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION test_catchExcepcion_MetodoErroneo
	* Note: Compruebo el correcto funcionamiento con la clase catchExcepcion
	*--------------------------------------------------------------------
		LOCAL lcExpectedValue, lcFileLog
		lcExpectedValue = 'Error, el verbo no es el correcto'
		lcFileLog = 'error.log'            && Es el archivo de salida con el log de la Exception
		TRY
			THIS.oObject.method = 'METODO_ERRONEO'
		CATCH TO loEx
			THIS.MessageOut('Esto me indica si es un error o algo generador por el programador: ' +loEx.Message)
			THIS.MessageOut('Valor de userValue: '+loEx.UserValue)
			THIS.AssertEquals(lcExpectedValue, loEx.UserValue, 'ERROR, se experaba otro valor')
			THIS.AssertTrue(FILE(lcFileLog), 'Error, no se encontro el archivo log: '+lcFileLog)
			THIS.MessageOut('Valor de Status: '+TRANSFORM(THIS.oObject.status))
		ENDTRY
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION test_catchExcepcion_URLNotExist
	* Note: Pruebo lo que sucede cuando se consulta a una url que no existe
	* La info de lo que sucede me llega por el objeto de la excepcion en 
	* la propiedad userValue en formato json
	*  ej:  {"status": 12007, "statustext": "Unknown"}
	*--------------------------------------------------------------------
		LOCAL lcResponseValue
		THIS.oObject.urlRequest = 'https://noexisteelsitio.com'
		THIS.oObject.method     = 'POST'
		THIS.oObject.addHeader  ("Content-Type", 'application/json')

		TRY
			lcResponseValue = THIS.oObject.SEND()
			THIS.MessageOut('Valor recibido: '+lcResponseValue)
			THIS.MessageOut('Valor de Status: '+TRANSFORM(THIS.oObject.status))
		CATCH TO loEx
			THIS.MessageOut('Valor de Status por el Erro: '+loEx.userValue)
		ENDTRY
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testGET_recepciondeunaImagen
	* Note: pruebo la recepcion de una image. La guardo en la carpeta 
	* images
	* Del primer GET, recibo un json con una direccion randon de la imagen a descargar.
	*     {"image":"http:\/\/randomfox.ca\/images\/59.jpg","link":"http:\/\/randomfox.ca\/?i=59"}
	* El segundo GET, descarga la imagen.
	*--------------------------------------------------------------------
		LOCAL lcResponseValue
		lcResponseValue = ''
		*--- Primera peticion, para obtener un nombre de archivo al azar
		THIS.oObject.urlRequest = 'https://randomfox.ca/floof/'
		THIS.oObject.method     = 'GET'
		THIS.oObject.addHeader  ("Content-Type", 'application/json')

		TRY
			lcResponseValue = THIS.oObject.SEND()
		CATCH TO loEx
			THIS.MessageOut('Valor de Status por el Error: '+loEx.userValue)
		ENDTRY

		THIS.MessageOut('Valor recibido: '+lcResponseValue)
		THIS.MessageOut('Valor de Status: '+TRANSFORM(THIS.oObject.status))

		*-- Segunda peticion, para descargar el archivo.
		lcURLImagen = SUBSTR(lcResponseValue,AT('"http',lcResponseValue)+1,;
											 AT('","link":',lcResponseValue)-AT('"http',lcResponseValue)-1)
		lcURLImagen = STRTRAN(lcURLImagen,'http:','https:')
		THIS.MessageOut('Imagen a descargar: '+lcURLImagen)

		lcResponseValue = ''
		THIS.oObject.urlRequest = lcURLImagen
		THIS.oObject.method     = 'GET'
		
		TRY
			lcResponseValue = THIS.oObject.SEND()
		CATCH TO loEx
			THIS.MessageOut('Valor de Status por el Error: '+loEx.userValue)
		ENDTRY

		STRTOFILE(lcResponseValue,'images\'+JUSTFNAME(lcURLImagen))
		THIS.MessageOut('Valor recibido: '+lcResponseValue)
		THIS.MessageOut('Valor de Status: '+TRANSFORM(THIS.oObject.status))
	ENDFUNC


	*--------------------------------------------------------------------
	FUNCTION testGET_OneCatJPG_usingParameters
	* Note: Test de envio de parametros para obtener una imagen
	*--------------------------------------------------------------------
		LOCAL lcResponseValue
		lcResponseValue = ''
		*--- Primera peticion, para obtener un nombre de archivo al azar
		THIS.oObject.method      = 'GET'
		THIS.oObject.urlRequest  = 'http://thecatapi.com/api/images/get'
		THIS.oObject.addParameter('format'          ,'src')
		THIS.oObject.addParameter('results_per_page','1')
		
		TRY
			lcResponseValue = THIS.oObject.SEND()
		CATCH TO loEx
			THIS.MessageOut('Valor de Status por el Error: '+loEx.userValue)
		ENDTRY

		lcNameFile = "cat"+SYS(3)+".jpg"
		STRTOFILE(lcResponseValue,'images\'+lcNameFile)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testPOST_DROPBOX_with_Header_and_Body_using_json
	* Note: A continuación detallo el POST solicitado según la doc de dropbox 
	*
	* POST /2/files/list_folder
	* Host: https://api.dropboxapi.com
	* User-Agent: api-explorer-client
	* Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d
	* Content-Type: application/json
	* {
	*     "path": ""
	* }
	*--------------------------------------------------------------------
		LOCAL lcExpectedValue, lcResponseValue
		lcExpectedValue = ''
		lcResponseValue = ''

		WITH THIS.oObject
			.urlRequest = 'https://api.dropboxapi.com/2/files/list_folder'
			.method     = 'POST'
			.addHeader  ("Content-Type", 'application/json')
			.addHeader  ("authorization", 'Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
			TEXT TO .Body PRETEXT 15 TEXTMERGE NOSHOW
{
	"path":""
}
			ENDTEXT		
			lcResponseValue = .SEND()
		ENDWITH

		*STRTOFILE(lcResponseValue,'dropbox.list_folder.txt')
		THIS.MessageOut('Valor recibido: '+lcResponseValue)
		THIS.MessageOut('Valor de Status: '+TRANSFORM(THIS.oObject.status))
		THIS.AssertFalse(EMPTY(lcResponseValue),'Error no se recibio una devolucion')
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testPOST_DROPBOX_SearchFile
	* Note: Busca un archivo en una carpeta especifica
	* https://dropbox.github.io/dropbox-api-v2-explorer/#files_search
	* Command cURL:
	* -------------
	* curl -X POST https://api.dropboxapi.com/2/files/search \
  	*      --header 'Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d' \
  	*      --header 'Content-Type: application/json' \
  	*      --data '{"path":"","query":"test01.txt"}'
	*--------------------------------------------------------------------
		LOCAL lcResponseValue
		lcResponseValue = ''
		WITH THIS.oObject
			.method     = 'POST'
			.urlRequest = 'https://api.dropboxapi.com/2/files/search'
			.addHeader  ('Authorization','Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
			.addHeader  ('Content-Type','application/json')
			.body       = '{"path":"","query":"test01.txt"}'
			lcResponseValue = .SEND()
		ENDWITH

		STRTOFILE(lcResponseValue,'dropbox.searchFile_OK.txt')
		THIS.MessageOut('Repuesta de la primera consulta: ')
		THIS.MessageOut(lcResponseValue)

		lcExpectedValue = '{"matches": [], "more": false, "start": 0}'
		WITH THIS.oObject
			.method     = 'POST'
			.urlRequest = 'https://api.dropboxapi.com/2/files/search'
			.addHeader  ('Authorization','Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
			.addHeader  ('Content-Type','application/json')
			.body       = '{"path":"","query":"noexiste.txt"}'
			lcResponseValue = .SEND()
		ENDWITH
		THIS.MessageOut('Repuesta de la segunda consulta: ')
		THIS.AssertEquals(lcExpectedValue, lcResponseValue, 'ERROR: se esperaba otro valor')
		STRTOFILE(lcResponseValue,'dropbox.searchFile_ERROR.txt')
		THIS.MessageOut(lcResponseValue)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testPOST_DROPBOX_uploadFile
	* Note: Sube un archivo al dropbox.
	* https://www.dropbox.com/developers/documentation/http/documentation#files-upload
	* Command cURL:
	* -------------
	*	curl -X POST https://content.dropboxapi.com/2/files/upload \
	* 		--header 'Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d' \
	* 		--header 'Content-Type: application/octet-stream' \
	* 		--header 'Dropbox-API-Arg: {"path":"/atari-et-video-game-howard-desk.jpg","autorename":false,"mode":{".tag":"add"},"mute":false}' \
	* 		--data-binary @'atari-et-video-game-howard-desk.jpg'
	*
	* Command HTTP:
	* ------------
	* POST /2/files/upload
	* Host: https://content.dropboxapi.com
	* User-Agent: api-explorer-client
	* Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d
	* Content-Type: application/octet-stream
	* Dropbox-API-Arg: {"path":"/atari-et-video-game-howard-desk.jpg","autorename":false,"mode":{".tag":"add"},"mute":false}
	* Content-Length: 48750
	*
	* --- (content of atari-et-video-game-howard-desk.jpg goes here) ---
	*--------------------------------------------------------------------
		LOCAL lcResponseValue, lcFileName, lcFileValue, lcFileSize
		lcResponseValue = ''
		lcFileName  = 'atari.jpg'
		lcFileName  = 'contratos.txt'
		*lcFileName  = 'Primeros.pdf'
		lcFileValue = FILETOSTR(lcFileName)
		lnFileSize  = LEN(lcFileValue)
		lnMaxSize   = 150*1000*1000 &&(150 Mb)
		IF lnFileSize>lnMaxSize THEN
			RETURN
		ENDIF
		WITH THIS.oObject
			.method     = 'POST'
			.urlRequest = 'https://content.dropboxapi.com/2/files/upload'
			.addHeader  ('Authorization','Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
			.addHeader  ('Content-Type','application/octet-stream')
			.addHeader  ('Dropbox-API-Arg','{"path":"/';
							+lcFileName;
							+'","autorename":false,"mode":{".tag":"add"},"mute":false}';
						 )
			.addHeader  ('Content-Length',TRANSFORM(lnFileSize)) 
			.body       = lcFileValue
			lcResponseValue = .SEND()
		ENDWITH

		*STRTOFILE(lcResponseValue,'dropbox.uploadFile.txt')
		THIS.MessageOut(lcResponseValue)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testPOST_DROPBOX_createFolder
	* Note: Crea una carpeta en la nube de DropBox
	* https://www.dropbox.com/developers/documentation/http/documentation#files-create_folder_v2
	* 
	* Command cURL:
	* -------------
	* curl -X POST https://api.dropboxapi.com/2/files/create_folder_v2 \
	* --header 'Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d' \
	* --header 'Content-Type: application/json' \
	* --data '{"path":"/creada desde vfox"}'
	* 
	* Command HTTP:
	* ------------
	* POST /2/files/create_folder_v2
	* Host: https://api.dropboxapi.com
	* User-Agent: api-explorer-client
	* Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d
	* Content-Type: application/json
	* 
	* {
	*     "path": "/creada desde vfox"
	* }
	*--------------------------------------------------------------------
		LOCAL lcResponseValue
		lcResponseValue = ''
		WITH THIS.oObject
			.method    = 'POST'
			.urlRequest= 'https://api.dropboxapi.com/2/files/create_folder_v2'
			.addHeader  ('Authorization','Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
			.addHeader  ('Content-Type','application/json')

			.body      = '{"path": "/creada desde vfox"}'
			lcResponseValue = .SEND()
		ENDWITH

		*STRTOFILE(lcResponseValue,'dropbox.createFolder.txt')
		THIS.MessageOut(lcResponseValue)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testPOST_DROPBOX_deleteFolder
	* Note: Elimina una carpeta en la nube de DROPBOX.
	* https://www.dropbox.com/developers/documentation/http/documentation#files-delete_v2
	*
	* Command cURL:
	* -------------
	* curl -X POST https://api.dropboxapi.com/2/files/delete_v2 \
	* 		--header 'Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d' \
	* 		--header 'Content-Type: application/json' \
	* 		--data '{"path":"/creada desde vfox"}'
  	*
  	* Command HTTP:
	* ------------
	* POST /2/files/delete_v2
	* Host: https://api.dropboxapi.com
	* User-Agent: api-explorer-client
	* Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d
	* Content-Type: application/json
	* 
	* {
	*     "path": "/creada desde vfox"
	* }
	*--------------------------------------------------------------------
		LOCAL lcResponseValue
		lcResponseValue = ''
		WITH THIS.oObject
			.method    = 'POST'
			.urlRequest= 'https://api.dropboxapi.com/2/files/delete_v2'
			.addHeader  ('Authorization','Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
			.addHeader  ('Content-Type','application/json')

			.body      = '{"path": "/creada desde vfox"}'
			lcResponseValue = .SEND()
		ENDWITH

		*STRTOFILE(lcResponseValue,'dropbox.deleteFolder.txt')
		THIS.MessageOut(lcResponseValue)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testPOST_DROPBOX_filesDownload
	* Note: Prepara la descarga de un archivo de la nube de DROPBOX
	* https://www.dropbox.com/developers/documentation/http/documentation#files-download
	*
	* Command cURL:
	* -------------
	* curl -X POST https://content.dropboxapi.com/2/files/download \
	* 		--header 'Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d' \
	* 		--header 'Dropbox-API-Arg: {"path":"/test01.txt"}' 
	*
  	* Command HTTP:
	* ------------
	* POST /2/files/download
	* Host: https://content.dropboxapi.com
	* User-Agent: api-explorer-client
	* Authorization: Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d
	* Dropbox-API-Arg: {"path":"/test01.txt"}
	*--------------------------------------------------------------------
		LOCAL lcResponseValue
		lcResponseValue = ''
		*-- Descargo un JPG
		lcFileName = 'atari.jpg'
		WITH THIS.oObject
			.method    = 'POST'
			.urlRequest= 'https://content.dropboxapi.com/2/files/download'
			.addHeader  ('Authorization',   'Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
			.addHeader  ('Dropbox-API-Arg', '{"path":"/';
												+lcFileName;
												+'"}')
			.addHeader  ('Content-Type',    'text/plain')

			.body      = ''
			lcResponseValue = .SEND()
		ENDWITH
		STRTOFILE(lcResponseValue,'result_test\tmp_'+lcFileName)

		*-- Descargo un TXT
		lcFileName = 'test01.txt'
		WITH THIS.oObject
			.addHeader  ('Dropbox-API-Arg', '{"path":"/';
												+lcFileName;
												+'"}')
			lcResponseValue = .SEND()
		ENDWITH
		STRTOFILE(lcResponseValue,'result_test\tmp_'+lcFileName)

		*-- Descargo un PDF
		lcFileName = 'Primeros pasos con Dropbox.pdf'
	*	lcFileName  = 'contratos.txt'
	*	lcFileName  = 'Primeros.pdf'
		WITH THIS.oObject
			.addHeader  ('Dropbox-API-Arg', '{"path":"/';
												+lcFileName;
												+'"}')
			lcResponseValue = .SEND()
		ENDWITH
		STRTOFILE(lcResponseValue,'result_test\tmp_'+lcFileName)
		THIS.MessageOut(lcResponseValue)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testSaveFile
	* Note:
	*--------------------------------------------------------------------
		LOCAL lcFolder, lcFile
		lcFolder = SYS(5)+ADDBS(CURDIR())+'download'
		lcFile   = 'cat'+SYS(3)+'.jpg'

		*--- 
		WITH THIS.oObject
			.method      = 'GET'
			.urlRequest  = 'http://thecatapi.com/api/images/get'
			.addParameter('format'          ,'src')
			.addParameter('results_per_page','1')
			.SEND()

			.pathDownload = lcFolder
			.saveFile(lcFile)
		ENDWITH

		THIS.AssertTrue(FILE(ADDBS(lcFolder)+lcFile),;
						'ERROR no se creo el archivo: '+lcFile)
	ENDFUNC

ENDDEFINE
*----------------------------------------------------------------------
* The three base class methods to call from your test methods are:
*
* THIS.AssertTrue	    (<Expression>, "Failure message")
* THIS.AssertEquals	    (<ExpectedValue>, <Expression>, "Failure message")
* THIS.AssertNotNull	(<Expression>, "Failure message")
* THIS.MessageOut       (<Expression>)
*
* Test methods (through their assertions) either pass or fail.
*----------------------------------------------------------------------

* AssertNotNullOrEmpty() example.
*------------------------------
*FUNCTION TestObjectWasCreated
*   THIS.AssertNotNullOrEmpty(THIS.oObjectToBeTested, "Test Object was not created")
*ENDFUNC
