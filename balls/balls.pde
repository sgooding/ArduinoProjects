#include <TVout.h>
#include <fontALL.h>


TVout TV;

struct Ball
{
 uint8_t r;
 uint8_t x;
 uint8_t y;
 int dx;
 int dy;
 
};
Ball ball;

struct Paddle
{
  int x, y, dy,l;
};
Paddle paddle;
bool pause;
int fps;
int count;
void setup() {
  TV.begin(NTSC,120,96);
  TV.select_font(font4x6);
  TV.println("Welcome To BALLS");
  TV.delay(2500);
  TV.println("\nBy Sean Gooding");
  TV.delay(1000);
  TV.clear_screen();
  
  
 ball.x = TV.hres()/2; // 60
 ball.y = TV.vres()/2; // 48
 ball.dx = 1;
 ball.dy = 1;
 fps = 1; 
 ball.r = 2;
 paddle.x = 3; 
 paddle.dy = 0;
 paddle.y = 6;
 paddle.l = 10;
 Serial.begin(9600);
 pause = false;
}

char buff[50];
char c_buff[50];

void print_ball()
{
 // sprintf(buff, "x(%d) y(%d) r(%d) px(%d) py(%d) s(%d) \n",ball.x,(int)ball.y,(int)ball.r,paddle.x, paddle.y, count);
  sprintf(buff,"%d Score ",count);
  TV.println(buff);
 // Serial.println(buff);
}

void check_collision()
{
    if( ball.x  >= uint8_t((int)TV.hres()-(int)ball.r) )
    {
        ball.dx = -ball.dx;
        ball.x  = uint8_t((int)TV.hres()-(int)ball.r) - 1;
    }
    if( ball.y >= uint8_t((int)TV.vres()-(int)ball.r) )
    {
        ball.dy = -ball.dy;
        ball.y = uint8_t((int)TV.vres()-(int)ball.r) - 1;
    }
    if( ( (int)ball.x + (int)(fps*ball.dx) ) < (paddle.x + (int)ball.r) ) 
    {
      if( (int)ball.y >= paddle.y && (int)ball.y <= paddle.y + paddle.l )
      {
   //     Serial.println("BOUNCE");
        ball.dx = -ball.dx;
        ball.x = ball.r + paddle.x + 1;
      }
      else
      {
   //     Serial.println("SCORE");
        ball.dx = 1;
        ball.dy = 1;
        ball.x = TV.hres()/2;
        ball.y = TV.vres()/2;
        count += 1;
      } 
    }
    if( (int)ball.y + (int)(fps*ball.dy )< (int)ball.r)
    {
     //   Serial.println((int)(fps*ball.dy ),DEC);
     //   Serial.println((int)ball.y + (int)(fps*ball.dy ),DEC);
        ball.dy = -ball.dy;
        ball.y = ball.r + 1;
    }
}

void update_position()
{
  ball.x = uint8_t((int)ball.x + ball.dx*fps);
  ball.y = uint8_t((int)ball.y + ball.dy*fps);

}
 
void loop(){
  TV.clear_screen();
  TV.draw_circle(ball.x,ball.y,ball.r,WHITE);
  TV.draw_line(paddle.x,paddle.y,paddle.x,paddle.y+paddle.l,WHITE);
  print_ball();
  TV.delay(10);  

  bool step_pause = false;
  if(Serial.available())
  {
    char k = (char)Serial.read();
    if( k == 'k' )
    {
      paddle.dy = -3;
    }
    else if( k == 'j' )
    {
      paddle.dy = 3;
    }
    else if ( k == 's' )
    {
      step_pause = true;
    }
    else if ( k == 'p' )
    {
      pause = !pause;
    }
    
  }  
  else
  {
    paddle.dy = 0;
  }
  
  if( !pause || step_pause)
  {
  update_position();
  step_pause = false;
  }

  paddle.y += paddle.dy;  
  
  check_collision();
}

