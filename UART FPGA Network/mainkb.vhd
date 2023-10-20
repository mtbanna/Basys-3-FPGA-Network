library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;
use work.uart_constants.ALL;


-- takes ascii codes from ps2_keyboard_to_ascii and makes an array with current displayed characters on screen
-- the array is sent to the display module to be displayed


entity mainkb is
      Port (
        clk : in std_logic;
        reset: in std_logic;
        rx_in    : in  STD_LOGIC;
        h_sync : out STD_LOGIC;                         --h_sync    
        v_sync : out STD_LOGIC;                         --v_sync
        r, g, b : out STD_LOGIC_VECTOR(3 downto 0)      --pixel color  
        );
end mainkb;

architecture Behavioral of mainkb is

component uart_rx is
  Port (
    clk,uart_clk,rst : in std_logic;
    rx_in : in std_logic;
    data : out std_logic_vector(6 downto 0);
    data_new : out std_logic    
    );
end component;


component Display is
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;                           --reset
        chars : in t_chars ; 
        countchx : in integer range 0 to H_CHARS-1;
        countchy : in integer range 0 to V_CHARS-1;                           
        h_sync : out STD_LOGIC;                         --h_sync    
        v_sync : out STD_LOGIC;                         --v_sync
        r, g, b : out STD_LOGIC_VECTOR(3 downto 0)      --pixel color  
    );
end component;

signal chars : t_chars;
signal countcharx : integer range 0 to H_CHARS-1 := 0;
signal countchary : integer range 0 to V_CHARS-1 := 0;
signal ascii_new : std_logic := '0';
signal ascii_code : std_logic_vector(6 downto 0) := "0000000";
signal past_ascii_new : std_logic := '0';

signal count : integer range 0 to BIT_TIME-1;
signal uart_clk : std_logic; -- 1 when count is 0 and 0 otherwise

begin
uart_rx_0: uart_rx  
    port map(clk=>clk,uart_clk=>uart_clk,rst=>reset,rx_in=>rx_in,data=>ascii_code,data_new=>ascii_new);   
display_0: Display 
    port map(clk=>clk,reset=>reset,chars=>chars,countchx=>countcharx,countchy=>countchary,h_sync=>h_sync,v_sync=>v_sync,r=>r,g=>g,b=>b);
    process(clk)
    begin
        if(rising_edge(clk))then
            if((past_ascii_new = '0') and (ascii_new = '1'))  then
                if(ascii_code = "0001000") then    --delete
                    if(countcharx > 0) then
                        countcharx<=countcharx-1;
                    elsif(countchary>0) then
                        countchary<=countchary-1;
                        countcharx<=H_CHARS-1;  
                    end if;
                         
                else
                    chars(countcharx,countchary)<=ascii_code;
                    countcharx<=countcharx+1;
                    if(countcharx=H_CHARS-1)then
                        countchary<=countchary+1;
                        countcharx<=0;
                    end if;
                end if;             
            end if;
            past_ascii_new <= ascii_new;
        end if;   
    end process;
    
    process(clk)    -- handling count and uart clk
    begin
        if(rising_edge(clk)) then
            if(count = 0) then
                count <= BIT_TIME - 1;
                uart_clk <= '1';
            else 
                count <= count-1;
                uart_clk <= '0';
            end if;
        end if;
    end process;
end Behavioral;
