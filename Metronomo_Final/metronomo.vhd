library ieee;
use ieee.std_logic_1164.all;

entity metronomo is
    generic (
        FRECUENCIA_RELOJ : positive := 50_000_000
    );
    port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        habilitar   : in  std_logic;
        tempo       : in  std_logic_vector(1 downto 0);
        pulso_led   : out std_logic;
        pulso_ritmo : out std_logic
    );
end entity metronomo;

architecture rtl of metronomo is
    -- Pulsos por minuto: 60, 90, 120 y 150.
    -- Dividir antes de multiplicar evita desbordamientos integer.
    constant CICLOS_60  : positive := (FRECUENCIA_RELOJ / 60)  * 60;
    constant CICLOS_90  : positive := (FRECUENCIA_RELOJ / 90)  * 60;
    constant CICLOS_120 : positive := (FRECUENCIA_RELOJ / 120) * 60;
    constant CICLOS_150 : positive := (FRECUENCIA_RELOJ / 150) * 60;
    constant ANCHO_LED  : positive := FRECUENCIA_RELOJ / 10; -- 100 ms

    signal periodo       : positive range 1 to FRECUENCIA_RELOJ := CICLOS_60;
    signal cuenta        : natural range 0 to FRECUENCIA_RELOJ := 0;
    signal cuenta_led    : natural range 0 to ANCHO_LED := 0;
    signal tempo_anterior: std_logic_vector(1 downto 0) := "00";
    signal tick          : std_logic := '0';
begin
    with tempo select periodo <=
        CICLOS_60  when "00",
        CICLOS_90  when "01",
        CICLOS_120 when "10",
        CICLOS_150 when others;

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            cuenta         <= 0;
            cuenta_led     <= 0;
            tempo_anterior <= "00";
            tick           <= '0';
        elsif rising_edge(clk) then
            tick <= '0';
            if habilitar = '0' then
                cuenta         <= 0;
                cuenta_led     <= 0;
                tempo_anterior <= tempo;
            elsif tempo /= tempo_anterior then
                cuenta         <= 0;
                cuenta_led     <= 0;
                tempo_anterior <= tempo;
            else
                if cuenta >= periodo - 1 then
                    cuenta     <= 0;
                    cuenta_led <= ANCHO_LED;
                    tick       <= '1';
                else
                    cuenta <= cuenta + 1;
                    if cuenta_led > 0 then
                        cuenta_led <= cuenta_led - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    pulso_led   <= '1' when cuenta_led > 0 else '0';
    pulso_ritmo <= tick;
end architecture rtl;
