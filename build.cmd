@echo off
cls

rem Usage:
rem
rem build
rem build pypi
rem build py2exe
rem build clean
rem build test
rem build cxf - not working for the moment
rem
rem Requires:
rem Python, Sphinx, Miktex, py.test, twine, py2exe, cxf, twine.

set OLDPATH=%PATH%
set PATH=d:\miktex\miktex\bin;%PATH%

if "%1"=="test" goto :TEST
if "%1"=="pypi" goto :PYPI

echo.
echo *** Cleanup and update basic info files
echo.
python setup_utils.py app_ver()
if not exist app_ver.txt goto :EXIT
for /f "delims=" %%f in (app_ver.txt) do set APP_VER=%%f
del app_ver.txt

python setup_utils.py app_name()
for /f "delims=" %%f in (app_name.txt) do set PROJECT=%%f
del app_name.txt

python setup_utils.py app_type()
for /f "delims=" %%f in (app_type.txt) do set PROJ_TYPE=%%f
del app_type.txt

python setup_utils.py py_ver()
for /f "delims=" %%f in (py_ver.txt) do set PY_VER=%%f
del py_ver.txt

python setup_utils.py update_copyright()

rd /s /q build
rd /s /q dist
rd /s /q %PROJECT%.egg-info
rd /s /q %PROJECT%-%APP_VER%
rd /s /q daysgrounded\doc
if exist *.pyc del *.pyc
if exist %PROJECT%\*.pyc del %PROJECT%\*.pyc

copy /y %PROJECT%\AUTHORS.rst %PROJECT%\AUTHORS.txt > nul
copy /y %PROJECT%\ChangeLog.rst %PROJECT%\ChangeLog.txt > nul
copy /y %PROJECT%\README.rst %PROJECT%\README.txt > nul
copy /y %PROJECT%\COPYING.rst %PROJECT%\COPYING.txt > nul
copy /y %PROJECT%\README.rst . > nul

if "%1"=="clean" goto :EXIT

if not exist test goto :DOC

echo.
echo *** DocTest/UnitTest
echo.
rem python -m doctest -v test/test.rst
rem python -m unittest discover -v -s test
py.test --cov-report term-missing --cov %PROJECT% -v test/
echo.
echo *** End of DocTest/UnitTest
echo.

if %ERRORLEVEL%==0 goto :DOC
goto :EXIT

:DOC
if not exist doc goto :NO_DOC

echo.
echo *** Sphinx
echo.
set SPHINXOPTS=-W -E

if not exist doc\index.ori ren doc\index.rst index.ori

python setup_utils.py prep_rst2pdf()

cd doc
cmd /c make clean
cmd /c make latex
cd _build\latex
pdflatex.exe %PROJECT%.tex
echo ***
echo *** Repeat to correct references
echo ***
pdflatex.exe %PROJECT%.tex
if not exist ..\..\..\%PROJECT%\doc md ..\..\..\%PROJECT%\doc
copy /y %PROJECT%.pdf ..\..\..\%PROJECT%\doc > nul
cd ..\..
del index.rst
ren index.ori index.rst

cmd /c make clean
cmd /c make html
xcopy /y /e _build\html\*.* ..\%PROJECT%\doc\ > nul

cmd /c make clean
cd ..

python setup_utils.py create_doc_zip()

echo.
echo *** End of Sphinx
echo.

:NO_DOC
pause
cls

if "%1"=="cxf" goto :CXF
if "%1"=="py2exe" goto :PY2EXE

:BUILD
python setup_utils.py sleep()

echo.
echo *** sdist build
echo.
python setup.py sdist
echo.
echo *** End of sdist build. Check for errors.
echo.
if %PROJ_TYPE%==module goto :MSG
pause
rem echo.
rem echo *** bdist_egg build
rem echo.
rem python setup.py bdist_egg
rem echo.
rem echo *** End of bdist_egg build. Check for errors.
rem echo.
rem pause
rem echo.
rem echo *** bdist_wininst build
rem echo.
rem python setup.py bdist_wininst
rem echo.
rem echo *** End of bdist_winist build. Check for errors.
rem echo.
rem pause
echo.
echo *** bdist_wheel build
echo.
python setup.py bdist_wheel
echo.
echo *** End of bdist_wheel build. Check for errors.
echo.

:MSG
echo.
echo *** If there were filesystem errors (eg. directory not empty), try repeating the build up to 3 times. At least on my system that works.
echo.

goto :EXIT

:TEST
echo.
echo *** TEST: Register, build and upload
echo.
python setup.py register -r test
echo.
echo *** End register
echo.
pause
cls

twine upload -r test dist/*
rem if %PROJ_TYPE%==module python setup.py sdist upload -r test
rem if %PROJ_TYPE%==module goto :EXIT
rem rem python setup.py sdist bdist_egg bdist_wininst bdist_wheel upload -r test
rem python setup.py sdist bdist_wheel upload -r test
goto :EXIT

:PYPI
echo.
echo *** PyPI: Register, build and upload
echo.
python setup.py register -r pypi
echo.
echo *** End register
echo.
pause
cls

twine upload dist/*
rem if %PROJ_TYPE%==module python setup.py sdist upload -r pypi
rem if %PROJ_TYPE%==module goto :EXIT
rem rem python setup.py sdist bdist_egg bdist_wininst bdist_wheel upload -r pypi
rem python setup.py sdist bdist_wheel upload -r pypi

rem upload docs

echo.
echo *** Don't forget to upload the pythonhosted.org/doc.zip to PyPI
echo.

goto :EXIT

:CXF
echo.
echo *** CXF
echo.
python cxf_setup.py build bdist_msi
rem python cxf_setup.py build_exe
rem cxfreeze cxf_setup.py build_exe
rem echo ***
rem echo *** Copy datafiles
rem echo ***
rem copy build\exe.win32-%PY_VER%\%PROJECT%\*.* build\exe.win32-%PY_VER%
goto :EXIT

:PY2EXE
echo.
echo *** PY2EXE
echo.
python setup.py py2exe
if exist dist\__main__.exe ren dist\__main__.exe %PROJECT%.exe

:EXIT
set PATH=%OLDPATH%
set OLDPATH=
set PY_VER=
set APP_VER=
set PROJ_TYPE=
set PROJECT=
set SPHINXOPTS=
