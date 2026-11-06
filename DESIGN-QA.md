# DESIGN-QA

No hay interfaz de producto. No hay lockup, ni captura a 390, 768 y 1280 px, ni Lighthouse. `SIGNAL_BRIEF.md` no estaba en el workspace; la fase 2 pide, cuando no hay UI, claridad y jerarquía en el informe y en la salida de terminal.

## Informe

El título dice qué auditoría es. Debajo, la corrida (versión, hora, archivos de evidencia). El resumen va en viñetas cortas. La integridad está antes que las consultas, en una cita y en una tabla de dos celdas con el cero. El diagrama va a continuación, con la cardinalidad escrita al lado de la imagen. Cada consulta tiene su encabezado, el número de filas y la tabla del resultado.

La tipografía es la del Markdown. No se añadió una hoja de estilos ni una fuente incrustada: no hay página que la sirva.

## Diagrama

`diagram.png` sale de diagram.4geeks.com en modo lectura, así que el PNG no arrastra los botones de borrar columna. La captura `evidence/diagram/tool_screen.png` sí muestra la barra del sitio (Undo, Redo, Export) y sirve para ver que el lienzo es el de la herramienta. No es una pantalla de la aplicación a tres anchos.

Las columnas largas (`completion_percentage`, `monthly_fee_paid`) se leen enteras. Las primarias llevan el marcador de clave del sitio y las foráneas el de enlace.

## Terminal

`evidence/psql-v2/` guarda la salida alineada de `psql`, con el SQL echo delante de cada resultado y el cierre `(N rows)`. El script escribe un sello de una línea por dato. Si un invariante no cuadra, el proceso termina con error y no imprime `assert=pass`.
