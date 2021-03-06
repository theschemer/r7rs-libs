:: Note, unless you preset bin on your CLASSPATH
:: This will produce 'missing class' errors as you compile on windows
:: the final jar file seems correct, however.

cd srfis/kawa
:: 27 needs compiling as a Java module
call kawa -d ../../bin -C srfi/27.sld
cd ../..

for %%f in srfi/*.sld do (
  echo %%f
  call kawa -d bin --r7rs -C "srfi/%%~nf.sld"
)

:: only one file from autodiff 
call kawa -d bin --r7rs -C autodiff/AD.sld

for %%d in (srfi nltk pfds r6rs rebottled robin slib weinholt) do (
  for %%f in (%%d/*.sld) do (
    echo %%d/%%f
    call kawa -d bin --r7rs -C "%%d/%%~nf.sld"
  )
)

cd bin
jar cf r7rs-libs.jar .
cd ..
move bin\r7rs-libs.jar .

