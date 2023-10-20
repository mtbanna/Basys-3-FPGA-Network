library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;

-- takes ascii codes from ps2_keyboard_to_ascii and makes an array with current displayed characters on screen
-- the array is sent to the display module to be displayed


entity mainkb is
      Port (
        clk : in std_logic;
        reset: in std_logic;
        ps2_clk    : in  STD_LOGIC;
        ps2_data   : in  STD_LOGIC;
        h_sync : out STD_LOGIC;                         --h_sync    
        v_sync : out STD_LOGIC;                         --v_sync
        r, g, b : out STD_LOGIC_VECTOR(3 downto 0)      --pixel color  
        );
end mainkb;

architecture Behavioral of mainkb is

COMPONENT ps2_keyboard_to_ascii IS
  GENERIC(
      clk_freq                  : INTEGER := 100_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 9);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      rst : in std_logic;
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
END COMPONENT;

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


begin
ps2_keyboard_to_ascii_0: ps2_keyboard_to_ascii  
    port map(clk=>clk,rst=> reset,ps2_clk=>ps2_clk,ps2_data=>ps2_data,ascii_new=>ascii_new,ascii_code=>ascii_code);   
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

end Behavioral;
