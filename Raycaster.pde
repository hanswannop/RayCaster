// Processing raycaster 
// 2013 Hans Wannop
// Processing Raycaster by Hans Wannop is licensed under a Creative Commons Attribution-NonCommercial 3.0 Unported License.

final static float FOV             = 70.0f;
final static float BLOCKSIZE       = 64.0f;
final static float PLAYERHEIGHT    = 48.0f;
final static int   LEVELWIDTH      = 16;
final static int   LEVELHEIGHT     = 16;
final static float MAPSCALE        = 0.125f;
final static float MOVESPEED       = 0.5f;
final static float ROTSPEED        = 0.1f;
final static int   LINEWIDTH       = 4;

int[][] levelData          = {
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1},
  {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
  {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 1, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 1},
  {2, 0, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 2},
  {1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, 
  {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1},
  {1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 2, 1, 0, 0, 0, 1},
  {2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};

float   playerX           = 512f;
float   playerY           = 512f;
float   moveX             = 0.0f;
float   moveY             = 0.0f;
float   playerAngle       = 270.0f;
color   horizontalColor   = color (255, 0, 0, 128); //Red
color   verticalColor     = color (0, 0, 255, 128); //Blue
float   distToPlane;         // Calculate in setup based on FOV and width
float   angleBetweenRays;    // Calculate in setup based on FOV and width
PImage  wallTextures[]    = new PImage[2];
PFont   font;

boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;
boolean ctrlPressed = false;
boolean altPressed = false;
color   groundBottom, groundTop, ceilingBottom, ceilingTop;

int prevTime = 0;
int deltaTime = 0;

void setup() {
  size(640, 480, P2D);
  wallTextures[0] = loadImage("wallTexture1.jpg");
  wallTextures[1] = loadImage("wallTexture2.jpg");
  distToPlane = (width/2)/tan(radians(FOV/2));
  angleBetweenRays = FOV/width;
  
  // Define colors
  groundBottom = color(128, 64, 0);
  groundTop = color(24, 12, 0);
  ceilingBottom = color(16);
  ceilingTop = color(128);
  
  // Setup font
  font = createFont("garamond", 15);
  textFont(font);
  textAlign(RIGHT, BOTTOM);
}

void draw() {
  deltaTime = millis() - prevTime;
  
  // Background
  setGradient(0, 0, width, height/2, ceilingTop, ceilingBottom);
  setGradient(0, height/2, width, height, groundTop, groundBottom);
  
  for (int i = 0; i < width; i+=LINEWIDTH) {
    // Cast ray
    float rayAngle = playerAngle - FOV/2 + (i*angleBetweenRays);
    float rayX = cos(radians(rayAngle));
    float rayY = sin(radians(rayAngle));
    boolean rayHit = false;

    // Intersection point for collision checks
    float xHorizontal = 0f;
    float yHorizontal = 0f;
    float xVertical = 0f;
    float yVertical = 0f;

    // Steping intervals to check for collision after intitial is found
    float stepXHorizontal = 0f;
    float stepYHorizontal = 0f;
    float stepXVertical = 0f;
    float stepYVertical = 0f;

    //Grid X, Y coordinates to check for collision check
    int gridX;
    int gridY;

    // Final closest hit point for ray
    float hitX = playerX;
    float hitY = playerY;

    //Distance to the closest intersection
    float distToLine = MAX_FLOAT;

    if (rayY<0) { // Ray is facing up

      yHorizontal = (int)(playerY/BLOCKSIZE) * BLOCKSIZE - 1; // minus 1 so blocks indexed from 0
      stepYHorizontal = -BLOCKSIZE;

      if (rayX<0) { // Ray is facing up & left
        stepXVertical = -BLOCKSIZE;
        stepXHorizontal = -BLOCKSIZE/(float)Math.tan(radians(rayAngle));
        stepYVertical = -BLOCKSIZE*(float)Math.tan(radians(rayAngle)); 
        xHorizontal =  playerX - ((playerY - yHorizontal) / (float)Math.tan(radians(rayAngle)));

        xVertical = (int)(playerX/BLOCKSIZE) * BLOCKSIZE - 0.001f; // next block left, minus 1 so blocks indexed from 0
        yVertical = playerY - (playerX - xVertical) * (float)Math.tan(radians(rayAngle));
      } 
      else {     // Ray is facing up & right
        stepXVertical = BLOCKSIZE;
        stepXHorizontal = -BLOCKSIZE/(float)Math.tan(radians(rayAngle));
        stepYVertical = BLOCKSIZE*(float)Math.tan(radians(rayAngle)); 
        xHorizontal =  playerX - ((playerY - yHorizontal) / (float)Math.tan(radians(rayAngle)));

        xVertical = (int)(playerX/BLOCKSIZE) * BLOCKSIZE + BLOCKSIZE; // next block right
        yVertical = playerY - (playerX - xVertical) * (float)Math.tan(radians(rayAngle));
      }
    } 
    else {     // Ray is facing down
      yHorizontal = (int)(playerY/BLOCKSIZE) * BLOCKSIZE + BLOCKSIZE; // minus 1 so blocks indexed from 0
      stepYHorizontal = BLOCKSIZE;

      if (rayX<0) { // Ray is facing down & left
        stepXVertical = -BLOCKSIZE;
        stepXHorizontal = BLOCKSIZE/(float)Math.tan(radians(rayAngle));
        stepYVertical = -BLOCKSIZE*(float)Math.tan(radians(rayAngle)); 
        xHorizontal =  playerX - ((playerY - yHorizontal) / (float)Math.tan(radians(rayAngle)));

        xVertical = (int)(playerX/BLOCKSIZE) * BLOCKSIZE - 0.001f; // next block left, minus 1 so blocks indexed from 0
        yVertical = playerY - (playerX - xVertical) * (float)Math.tan(radians(rayAngle));
      } 
      else {     // Ray is facing down & right
        stepXVertical = BLOCKSIZE;
        stepXHorizontal = BLOCKSIZE/(float)Math.tan(radians(rayAngle));
        stepYVertical = BLOCKSIZE*(float)Math.tan(radians(rayAngle)); 
        xHorizontal =  playerX - ((playerY - yHorizontal) / (float)Math.tan(radians(rayAngle)));

        xVertical = (int)(playerX/BLOCKSIZE) * BLOCKSIZE + BLOCKSIZE; // next block right
        yVertical = playerY - (playerX - xVertical) * (float)Math.tan(radians(rayAngle));
      }
    }
    float brightness = 0;
    int u = 0;
    int texIndex = 0;
    //Check next horizontal intersections
    while (!rayHit && xHorizontal >= 0 && yHorizontal >= 0 && xHorizontal <= (BLOCKSIZE*LEVELWIDTH) && yHorizontal <= (BLOCKSIZE*LEVELHEIGHT)) { 

      //rect(xHorizontal*MAPSCALE, yHorizontal*MAPSCALE, 1, 1); // Draw hit checks
      
      gridX = (int)(xHorizontal/BLOCKSIZE);
      gridY = (int)(yHorizontal/BLOCKSIZE);
      if (gridX < LEVELWIDTH && gridY < LEVELHEIGHT && gridX >= 0 && gridY >= 0 && levelData[gridY][gridX]>0) {
        texIndex = levelData[gridY][gridX]-1;
        rayHit = true;
        distToLine = (float)Math.sqrt((playerX-xHorizontal)*(playerX-xHorizontal)+(playerY-yHorizontal)*(playerY-yHorizontal));
        hitX = xHorizontal;
        hitY = yHorizontal;
        u = int(hitX % BLOCKSIZE); // Texture U coordinate
        brightness = 1-distToLine/(LEVELWIDTH*BLOCKSIZE);
        noStroke();
      }
      xHorizontal += stepXHorizontal;
      yHorizontal += stepYHorizontal;
    }

    rayHit = false;

    while (!rayHit && xVertical >= 0 && yVertical >= 0 && xVertical <= (BLOCKSIZE*LEVELHEIGHT) && yVertical <= (BLOCKSIZE*LEVELHEIGHT)) { //Check vertical intersections

      //rect(xVertical*MAPSCALE, yVertical*MAPSCALE, 1, 1); // Draw hit checks
      
      gridX = (int)(xVertical/BLOCKSIZE);
      gridY = (int)(yVertical/BLOCKSIZE);
      if (gridX < LEVELWIDTH && gridY < LEVELHEIGHT && gridX >= 0 && gridY >= 0 && levelData[gridY][gridX]>0) {
        rayHit = true;
        float dist = (float)Math.sqrt((playerX-xVertical)*(playerX-xVertical)+(playerY-yVertical)*(playerY-yVertical));
        if (dist < distToLine) {
          texIndex = levelData[gridY][gridX]-1;
          distToLine = dist;
          hitX = xVertical;
          hitY = yVertical;
          u = int(hitY % BLOCKSIZE); // Texture U coordinate
          brightness = (1-distToLine/(LEVELWIDTH*BLOCKSIZE))/2;
          noStroke();
        }
      }
      xVertical += stepXVertical;
      yVertical += stepYVertical;
    }

    // DRAW THE SLICE

    // Vertical clipping
    float lineHeight = (BLOCKSIZE / distToLine) * distToPlane;
    float drawHeight;
    if (lineHeight > height){
      drawHeight = height;
    } else {
      drawHeight = lineHeight;
    }
    float startV = (lineHeight-drawHeight)/2; // Calc texture offset for vetical clipping

    // Texture mapping
    for (int j = 0; j < drawHeight ; j+=LINEWIDTH){ 
        int v = int(((j + startV)/ lineHeight) * BLOCKSIZE); // y position on texture          
        color c = wallTextures[texIndex].pixels[u + v*64]; // get color from pixel array location
        fill(red(c)*brightness, green(c)* brightness, blue(c)*brightness);
        rect(i, height/2-drawHeight/2+j, LINEWIDTH, LINEWIDTH );
    }
    
    //Draw ray on map
    stroke(0, 255, 0, 128);
    line(playerX*MAPSCALE, playerY*MAPSCALE, hitX*MAPSCALE, hitY*MAPSCALE );

    //Draw view arc on map
    //stroke(255, 0, 255);
    //fill(255, 0, 255);
    //arc(playerX*MAPSCALE, playerY*MAPSCALE, 20, 20, radians(playerAngle-(FOV)/2), radians(playerAngle+(FOV)/2));
  }
  
  
  stroke(255);
  fill(0);

  // Draw the map
  for (int i= 0; i < LEVELHEIGHT; i++) {
    for (int j= 0; j < LEVELWIDTH; j++) {
      if (levelData[i][j] > 0) {
        rect (j*BLOCKSIZE*MAPSCALE, i*BLOCKSIZE*MAPSCALE, BLOCKSIZE*MAPSCALE, BLOCKSIZE*MAPSCALE);
      }
    }
  }
  
  //Instructions
  fill(255);
  text("Use arrow keys to move", width-20, height-20);
  
  

  // UPDATE MOVEMENT
  float moveX = 0.0f;
  float moveY = 0.0f;
  float rot = 0.0f;
  if (upPressed) moveY -= 1.0f;
  if (downPressed) moveY += 1.0f;
  if (altPressed) {
    if (leftPressed) moveX -= 1.0f;
    if (rightPressed) moveX += 1.0f;
  } 
  else {
    if (leftPressed) rot -= 1.0f;
    if (rightPressed) rot += 1.0f;
  }


  playerX-= cos(radians(playerAngle)) * (moveY*MOVESPEED*deltaTime);
  playerY-= sin(radians(playerAngle)) * (moveY*MOVESPEED*deltaTime);
  playerX-= sin(radians(playerAngle)) * (moveX*MOVESPEED*deltaTime);
  playerY+= cos(radians(playerAngle)) * (moveX*MOVESPEED*deltaTime);
  playerAngle+=rot*ROTSPEED*deltaTime;
  
  prevTime = millis();
}

void setGradient(int x, int y, float w, float h, color c1, color c2) {
  noFill();
  for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
  }
}

void keyPressed()
{
  if (key == CODED) {
    if (keyCode == UP) upPressed = true;
    if (keyCode == DOWN) downPressed = true;
    if (keyCode == LEFT) leftPressed = true;
    if (keyCode == RIGHT) rightPressed = true;
    if (keyCode == CONTROL) ctrlPressed = true;
    if (keyCode == ALT) altPressed = true;
  }
}

void keyReleased()
{
  if (key == CODED) {
    if (keyCode == UP) upPressed = false;
    if (keyCode == DOWN) downPressed = false;
    if (keyCode == LEFT) leftPressed = false;
    if (keyCode == RIGHT) rightPressed = false;
    if (keyCode == CONTROL) ctrlPressed = false;
    if (keyCode == ALT) altPressed = false;
  }
}
