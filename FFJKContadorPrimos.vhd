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

ENTITY ffjkcontsync IS
    -- portas
    PORT (
        clk : IN STD_LOGIC;
        preset : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        Q : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ffjkcontsync;
ARCHITECTURE RTL OF ffjkcontsync IS
    -- portas
    COMPONENT JK_FF IS
        PORT (
            J : IN STD_LOGIC;
            K : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            preset : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            Q : OUT STD_LOGIC
        );
    END COMPONENT;
    -- sinais
    SIGNAL contagem : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"; -- ABCD / [0] = A, [1] = B, [2] = C, [3] = D
    SIGNAL J_output : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL K_output : STD_LOGIC_VECTOR (3 DOWNTO 0);
BEGIN
    -- D
    J_output(0) <= '1';
    K_output(0) <= NOT(contagem(1)) AND NOT(contagem(2)); -- !B!C

    -- C
    J_output(1) <= NOT(contagem(0)) AND contagem(3); -- !AD
    K_output(1) <= NOT(contagem(1)) AND contagem(3); -- !BD

    -- B
    J_output(2) <= contagem(2) AND contagem(3); -- CD
    K_output(2) <= contagem(2) OR contagem(0); -- C + A

    -- A
    J_output(3) <= contagem(1) AND contagem(2); -- BC
    K_output(3) <= NOT(contagem(2)); -- !C

    FFD : JK_FF PORT MAP(J => J_output(0), K => K_output(0), clk => clk, preset => preset, reset => reset, Q => contagem(3));

    FFC : JK_FF PORT MAP(J => J_output(1), K => K_output(1), clk => clk, preset => preset, reset => reset, Q => contagem(2));

    FFB : JK_FF PORT MAP(J => J_output(2), K => K_output(2), clk => clk, preset => preset, reset => reset, Q => contagem(1));

    FFA : JK_FF PORT MAP(J => J_output(3), K => K_output(3), clk => clk, preset => preset, reset => reset, Q => contagem(0));

    Q <= contagem;
END RTL;
