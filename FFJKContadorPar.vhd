LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY JK_FF IS
    -- portas
    PORT (
        J : IN STD_LOGIC;
        K : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        preset : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        Q : OUT STD_LOGIC
    );
END JK_FF;
ARCHITECTURE RTL OF JK_FF IS
    --sinais
    SIGNAL FF_input : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL Def_Val : STD_LOGIC := '0';
BEGIN
    FF_input <= J & K;
    PROCESS (clk, preset, reset)
    BEGIN
        IF (preset = '1') THEN
            IF (reset = '0') THEN
                Def_Val <= '0';
            ELSIF (falling_edge (clk)) THEN-- borda descida
                CASE(FF_input) IS
                    WHEN "00" => Def_Val <= Def_Val;
                    WHEN "01" => Def_Val <= '0';
                    WHEN "10" => Def_Val <= '1';
                    WHEN OTHERS => Def_Val <= NOT(Def_Val);
                END CASE;

            END IF;
        END IF;
    END PROCESS;
    Q <= Def_Val;
END RTL;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ffjkcontpar IS
    -- portas
    PORT (
        clk : IN STD_LOGIC;
        preset : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        Q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ffjkcontpar;
ARCHITECTURE RTL OF ffjkcontpar IS
    -- portas
    COMPONENT JK_FF IS
        PORT (
            J : IN STD_LOGIC;
            K : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            preset : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            Q : OUT STD_LOGIC);
    END COMPONENT;
    -- sinais
    SIGNAL temp : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
    SIGNAL JK_output : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN
    -- componentes conexao
    FF1 : JK_FF PORT MAP(J => '1', K => '1', clk => clk, preset => preset, reset => reset, Q => temp(0));
    JK_output(0) <= NOT('0') AND temp(0);

    FF2 : JK_FF PORT MAP(J => JK_output(0), K => JK_output(0), clk => clk, preset => preset, reset => reset, Q => temp(1));
    JK_output(1) <= temp(0) AND temp(1);

    FF3 : JK_FF PORT MAP(J => JK_output(1), K => JK_output(1), clk => clk, preset => preset, reset => reset, Q => temp(2));
    JK_output(2) <= (temp(0) AND '0') OR (temp(2) AND JK_output(1));

    Q(0) <= '0';
    Q(1) <= temp(0);
    Q(2) <= temp(1);
    Q(3) <= temp(2);
END RTL;
