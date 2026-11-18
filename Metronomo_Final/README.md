# Metrónomo digital para la Terasic DE10-Lite

Este proyecto final de VLSI usa la FPGA MAX 10 `10M50DAF484C7G` para hacer parpadear el LED rojo `LEDR0` a cuatro velocidades. Un metrónomo marca un ritmo con golpes regulares. Aquí vemos cada golpe como un destello.

## Archivos del proyecto

| Archivo                    | Para qué sirve 
| ---                        | --- 
| `Prueba_Metronomo_BDF.qpf` | Abre el proyecto en Quartus. 
| `Prueba_Metronomo_BDF.qsf` | Guarda el dispositivo, el diagrama principal, los archivos y los pines. 
| `top_metronomo_bdf.bdf`    | Es el diagrama principal. Conecta los controles de la tarjeta con el bloque del metrónomo y con el LED. 
| `metronomo.vhd`            | Contiene el código que cuenta el tiempo y genera los pulsos.
| `metronomo.bsf`            | Es el símbolo del bloque VHDL que se puede colocar al editar el diagrama. 
| `metronomo.sdc`            | Le dice a Quartus que el reloj tiene un periodo de 20 ns. 

## Cómo funciona

El reloj de la placa funciona a 50 MHz. Eso significa que da 50 millones de ciclos por segundo y que cada ciclo dura 20 ns. El código cuenta esos ciclos hasta que toca marcar un golpe. Luego vuelve a empezar la cuenta y enciende el LED durante 100 ms. Si cambias la velocidad o desactivas el metrónomo, la cuenta vuelve a cero.

El botón **KEY0** funciona como **RESET**. Al presionarlo, la señal `reset_n` baja a 0, se reinician los contadores y se apaga el LED. Al soltarlo, la cuenta puede empezar otra vez si `SW0` está encendido.

La salida `pulso_ritmo` se activa durante un solo ciclo de reloj en cada golpe. Se podría usar como señal para otro bloque. Actualmente está sin conexión en el BDF y el LED usa la salida `pulso_led`.

## Entradas, salidas y pines
| Señal en la tarjeta        | Tipo             | Función                        | Pin        | Estándar eléctrico                          |
| :------------------------- | :--------------- | :----------------------------- | :--------- | :------------------------------------------ |
| `MAX10_CLK1_50`            | Entrada          | Reloj de 50 MHz                | `PIN_P11`  | 3.3-V LVTTL                                 |
| `KEY0`                     | Entrada          | Reinicio al presionar          | `PIN_B8`   | 3.3 V Schmitt Trigger                       |
| `SW0`                      | Entrada          | Activa o apaga el metrónomo    | `PIN_C10`  | 3.3-V LVTTL                                 |
| `SW1` (`SW[1]` en Quartus) | Entrada          | Bit bajo de la velocidad       | `PIN_C11`  | 3.3-V LVTTL                                 |
| `SW2` (`SW[2]` en Quartus) | Entrada          | Bit alto de la velocidad       | `PIN_D12`  | 3.3-V LVTTL                                 |
| `LEDR0`                    | Salida           | Destello con cada golpe        | `PIN_A8`   | 3.3-V LVTTL, corriente de salida de 4 mA    |
| `pulso_ritmo`              | Salida del bloque| Pulso de un ciclo por golpe    | Sin conexión | —                                         |

## Velocidades

**BPM** significa **golpes por minuto**. A 60 BPM hay un golpe cada segundo.

Con **SW0 = 0**, el metrónomo está apagado. Con **SW0 = 1**, **SW1 y SW2 trabajan juntos** para elegir la velocidad.

| SW2 | SW1 | Velocidad |
| --- | --- | --------- |
| 0   | 0   | 60 BPM    |
| 0   | 1   | 90 BPM    |
| 1   | 0   | 120 BPM   |
| 1   | 1   | 150 BPM   |

## Abrir y compilar en Quartus

1. Abre Quartus Prime Lite 25.1 con el soporte para MAX 10 instalado.
2. Ve a **File → Open Project** y abre `Prueba_Metronomo_BDF.qpf`. Mantén los seis archivos del proyecto juntos.
3. Abre `top_metronomo_bdf.bdf` para ver las conexiones. La entidad principal del proyecto es `top_metronomo_bdf`.
4. Ve a **Processing → Start Compilation**. Revisa el resultado. Una compilación correcta genera `output_files/Prueba_Metronomo_BDF.sof`.

## Programar la DE10-Lite por USB-Blaster

1. Conecta y enciende la placa. Conecta el cable USB al puerto USB-Blaster de la DE10-Lite y a la computadora.
2. En Quartus abre **Tools → Programmer**. En **Hardware Setup**, selecciona **USB-Blaster**. En **Mode**, selecciona **JTAG**.
3. Si hace falta, usa **Auto Detect** para detectar el MAX 10. En su fila agrega el archivo `output_files/Prueba_Metronomo_BDF.sof` con **Change File** o **Add File**, según lo que muestre el programador.
4. Marca **Program/Configure**, pulsa **Start** y espera a que el progreso llegue al 100 %.
5. Pon `SW0` en 1 y observa `LEDR0`. Cambia `SW1` y `SW2` para seleccionar el ritmo.

[Guía del programador de Quartus](https://www.intel.com/programmable/technical-pdfs/683039.pdf)

## Pruebas realizadas

- Se programó la Terasic DE10-Lite mediante USB-Blaster. En la placa se observó que `LEDR0` parpadeaba y que cambiar `SW1` y `SW2` modificaba la velocidad.
- La advertencia 15714 se corrigió. El registro de la compilación posterior en Quartus Prime Lite 25.1 muestra **0 errores y 15 advertencias**. Incluye avisos sobre la cantidad de procesadores de compilación, la licencia para LogicLock y las interfaces eléctricas. El análisis de tiempo también mostró advertencias críticas por falta de una asignación de incertidumbre del reloj.
- El 18 de noviembre de 2026 se compiló esta versión desde una copia limpia con Quartus Prime Lite 25.1std.0. La compilación terminó con **0 errores y 15 advertencias**, sin la advertencia 15714, y generó el `.sof`. Quartus reconoció el bloque `metronomo` y leyó el reloj de 20 ns del SDC. Las observaciones en la placa corresponden a la prueba física previa.


