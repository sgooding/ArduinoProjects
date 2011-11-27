#include <TVout.h>
#include <fontALL.h>

TVout TV;

struct Point
{
  int x,y;
};

struct Screen
{
  Point top_left;
  Point bot_right;
  Point c;
};
Screen screen;

int key;

bool turn;
int places[9];

void setup() 
{
  TV.begin(NTSC,120,96);
  TV.select_font(font4x6);
  TV.println("Welcome To TicTacToe");
  TV.delay(2500);
  TV.println("\nBy Sean Gooding");
  TV.delay(1000);
  TV.clear_screen();
  
  screen.top_left.x = 0;
  screen.top_left.y = 5;
  screen.bot_right.x = TV.hres();
  screen.bot_right.y = TV.vres();
  screen.c.x = TV.hres()/2;
  screen.c.y = TV.vres()/2;
  key = -1;
  turn = true;
  Serial.begin(9600);

  for( int i = 0; i < 9; i++ )
    places[i] = -1;  
}


void draw_screen()
{ 
  for( int i = 1; i <= 4; i++ )
  {
    TV.draw_line(20*i,   20,   20*i, 20*4,     WHITE);
    TV.draw_line(20,     20*i, 20*4, 20*i,     WHITE); 
  } 
  
  for( int i = 0; i < 9; i++ )
  {
  if( places[i] >= 0 )
  {
    
    int c = (i)%3;
    int r = ((i) - c)/3;
    if( places[i] == 0 )
    {
      TV.draw_circle( c*20 + 30, r*20 + 30, 4, WHITE );
    }
    else if( places[i] == 1 )
    {
      TV.draw_line( (c+1)*20 + 2, (r+1)*20 + 2, 
                    (c+2)*20 - 2, (r+2)*20 - 2, WHITE );
     
      TV.draw_line( (c+2)*20 - 2, (r+1)*20 + 2, 
                    (c+1)*20 + 2, (r+2)*20 - 2, WHITE );              
    }
  } 
  }



}

void loop()
{
  draw_screen();
  //blank_screen();
  
  if(Serial.available())
  {
    key = Serial.read();
    if( key > 47 && key < 58 )
    {
      key -= 48;
      if( places[key-1] < 0 )
      {
        places[key-1] = turn;
        turn = !turn;
      }
    }
    else
    {
      key = -1;
    }
    
  }

}
