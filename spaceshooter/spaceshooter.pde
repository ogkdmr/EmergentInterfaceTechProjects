//Originally made and coded by Logan Fitzgerald using Processing3

ArrayList<Star> stars = new ArrayList<Star>();
int frequency = 4; //frequency of star | LOWER == MORE STARS

Ship playerShip;

//This is the variable that defines the movement of the ship. Updated by the readPipe() method.
String gesture; 

ArrayList<Asteroid> asteroids = new ArrayList<Asteroid>();
int asteroidFrequency = 75; // LOWER == MORE ASTEROIDS

//OPTION ONE -- A single bullet at a time
//Bullet bullet;

//OPTION TWO -- Multiple bullets at a time
ArrayList<Bullet> bullets = new ArrayList<Bullet>();

int points;

EndScene end;

void setup() {
  // fullScreen(P2D);
  size(700, 700);
  playerShip = new Ship();
  frameRate(30);
  points = 0;
  
  //starting to listen to the com4 port for arduino.
}

void draw() {

  if (end != null) {
    end.drawEndScene();
  } else { 
    background(0);
    drawStar();

    drawAsteroid();
    fill(255, 0, 0);
    stroke(255);
    drawBullet();
   
    //start an asychronous thread to read the data from the "myfifo" pipe between recognition engine and this sketch.
    thread("readPipe");
    //print("read gesture: "+ gesture);
    
    if(gesture!= null){
      reactToGesture(gesture);
    }
    
    
    playerShip.drawShip();

    stroke(255);
    fill(255);
    textSize(30);
    text("Points: " + points, 50, 50);

    checkCollision();
 
  }
}


//Resets the parameters that track the ships motion so that the motion stops when the gesture stops.

void refreshLastGesture(){
  playerShip.leftPressed = false;
  playerShip.rightPressed = false;
}

/*
  Helper method that updates the ship's direction based on the last gesture read by the engine in the other sketch.
  ** To be called within the draw() loop.

*/

void reactToGesture(String lastGesture){
    
    refreshLastGesture();
  
    if(lastGesture.equals("Touch")){
       playerShip.leftPressed = true;
    }
    
    if(lastGesture.equals("Grab")){
       playerShip.rightPressed = true;
    }
    
    if(lastGesture.equals("In water")){
       //I want maximum 5 bullets at any given time.
       if(bullets.size()<=5){
         Bullet b = new Bullet(playerShip);
         bullets.add(b);
       }
    }

}  


void drawBullet() {
 
    for (int i = 0; i< bullets.size(); i++) {
      //i is every number from 0 to the size of the bullet array
      //println(bullets.get(i).x);
      bullets.get(i).drawBullet();
    }
  }


void checkCollision() {
  for (int i = 0; i < asteroids.size(); i++) {
    Asteroid a = asteroids.get(i);
    if (a.checkCollision(playerShip) == true) {
      end = new EndScene(points);
    }
    for (int b = 0; b < bullets.size(); b++) {
      Bullet bullet = bullets.get(b);
      if (a.checkCollision(bullet) == true) {
        //set up removal of bullet and astroid

        points++;

        asteroids.remove(a);
        bullets.remove(bullet);
        i--;
        b--;
      }
    }
  }
}


void drawAsteroid() {
  if (frameCount % asteroidFrequency == 0) {
    asteroids.add(new Asteroid(random(150, 250)));
  }
  for (int i = 0; i<asteroids.size(); i++) {
    Asteroid currentAsteroid = asteroids.get(i);
    currentAsteroid.drawAsteroid();
    if (currentAsteroid.y > height + currentAsteroid.size) {
      asteroids.remove(currentAsteroid);
      i--;
      points--;
    }
  }
  //prinln(asteroids.size());
}

void drawStar() {
  strokeWeight(8);
  stroke(255);
  if (frameCount % frequency == 0) {
    Star myStar = new Star();
    stars.add(myStar);
  }
  for (int i = 0; i<stars.size(); i++) {
    Star currentStar = stars.get(i);
    currentStar.drawStar();
  }


//leaving these here but they won't be needed since I changed the way user interacts with the game.
//no more keystrokes anymore, instead gestures.
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      playerShip.upPressed = true;
    } else if (keyCode == DOWN) {
      playerShip.downPressed = true;
    } else if (keyCode == LEFT) {
      playerShip.leftPressed = true;
    } else if (keyCode == RIGHT) {
      playerShip.rightPressed = true;
    }
  } else if (key == ' ') {
    Bullet b = new Bullet(playerShip);
    bullets.add(b);

    //if (bullet == null) {
    //bullet = new Bullet(playShip);
    //}

    //Assume we're in the right location
    //bullet = null;
  }
}


//Leaving these here but they won't be needed.
void keyReleased() {
  if (keyCode == UP) {
    playerShip.upPressed = false;
  } else if (keyCode == DOWN) {
    playerShip.downPressed = false;
  } else if (keyCode == LEFT) {
    playerShip.leftPressed = false;
  } else if (keyCode == RIGHT) {
    playerShip.rightPressed = false;
  }
}

void mousePressed() {
  if (end != null && end.mouseOverButton() == true) {
    resetGame();
  }
}

void resetGame() {
  stars.clear();
  bullets.clear();
  asteroids.clear();
  playerShip = new Ship();
  end = null;
  points = 0;
}


/*
Reading the data that the recognition engine is passing over.
*/
void readPipe(){
  
  try{
  String[] s = loadStrings("../myfifo");
  gesture = s[0];
  //println(gesture);
  }
  catch(ArrayIndexOutOfBoundsException exp){
    //do nothing because it does not affect the game play or crash the game etc.
  }
}
