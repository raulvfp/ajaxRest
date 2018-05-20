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
		THIS.oObject.addHeader("Content-Type", 'application/json')
		THIS.oObject.addParameters("text", 'Prueba%20vfp9')

		lcResponseValue = THIS.oObject.SEND()
		THIS.AssertEquals(lcExpectedValue, lcResponseValue,'Error el resultado no es deseado')
		THIS.MessageOut('Valor recibido: '+lcResponseValue)
	ENDFUNC

	*--------------------------------------------------------------------
	FUNCTION testPost_with_Header_and_Body_using_json
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

		THIS.oObject.urlRequest = 'https://api.dropboxapi.com/2/files/list_folder'
		THIS.oObject.method     = 'POST'
		THIS.oObject.addHeader   ("HttpVersion"  ,'1.1')
		THIS.oObject.addHeader   ("Content-Type", 'application/json')
		THIS.oObject.addHeader   ("authorization", 'Bearer 2BaNplW-NkAAAAAAAAAACnD2uYsT9R8Kvoy0hg-BWunSrO2M4awBI75Ggf0FEb-d')
		TEXT TO THIS.oObject.Body PRETEXT 15 TEXTMERGE NOSHOW
{
	"path":"",
	"recursive":false
}
		ENDTEXT		

		lcResponseValue = THIS.oObject.SEND()
		THIS.MessageOut('Valor recibido: '+lcResponseValue)
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
