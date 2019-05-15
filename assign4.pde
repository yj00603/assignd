PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, stone1, stone2, soilEmpty;
PImage soldier;
PImage[][] soils, stones;

final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

int[][] soilHealth;

final int START_BUTTON_WIDTH = 144;
final int START_BUTTON_HEIGHT = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

float[] cabbageX, cabbageY, soldierX, soldierY, soilEmptyX, soilEmptyY, soilEmptyX1, soilEmptyY1;
float soldierSpeed = 2f;

float playerX, playerY;
int playerCol, playerRow;
final float PLAYER_INIT_X = 4 * SOIL_SIZE;
final float PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false;
boolean rightState = false;
boolean downState = false;
int playerHealth = 2;
final int PLAYER_MAX_HEALTH = 5;
int playerMoveDirection = 0;
int playerMoveTimer = 0;
int playerMoveDuration = 15;

boolean demoMode = false;

void setup() {
  size(640, 480, P2D);
  bg = loadImage("img/bg.jpg");
  title = loadImage("img/title.jpg");
  gameover = loadImage("img/gameover.jpg");
  startNormal = loadImage("img/startNormal.png");
  startHovered = loadImage("img/startHovered.png");
  restartNormal = loadImage("img/restartNormal.png");
  restartHovered = loadImage("img/restartHovered.png");
  groundhogIdle = loadImage("img/groundhogIdle.png");
  groundhogLeft = loadImage("img/groundhogLeft.png");
  groundhogRight = loadImage("img/groundhogRight.png");
  groundhogDown = loadImage("img/groundhogDown.png");
  life = loadImage("img/life.png");
  soldier = loadImage("img/soldier.png");
  cabbage = loadImage("img/cabbage.png");

  soilEmpty = loadImage("img/soils/soilEmpty.png");


  // Load PImage[][] soils
  soils = new PImage[6][5];
  for(int i = 0; i < soils.length; i++){
    for(int j = 0; j < soils[i].length; j++){
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
    }
  }

  // Load PImage[][] stones
  stones = new PImage[2][5];
  for(int i = 0; i < stones.length; i++){
    for(int j = 0; j < stones[i].length; j++){
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
    }
  }

  // Initialize player
  playerX = PLAYER_INIT_X;
  playerY = PLAYER_INIT_Y;
  playerCol = (int) (playerX / SOIL_SIZE);
  playerRow = (int) (playerY / SOIL_SIZE);
  playerMoveTimer = 0;
  playerHealth = 2;

  // Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
  
  int[] emptySoils = new int[SOIL_ROW_COUNT];
  
    for(int j = 0; j < SOIL_ROW_COUNT; j++){
    emptySoils[j] = ( j == 0 ) ? 0 : floor(random(1, 3));
  }
  
  for(int i = 0; i < soilHealth.length; i++){
    for (int j = 0; j < soilHealth[i].length; j++) {
       // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
    float randRes = random(SOIL_COL_COUNT - i);

      if(randRes < emptySoils[j]){

        soilHealth[i][j] = 0;
        emptySoils[j] --;

      }else{

        soilHealth[i][j] = 15;

        if(j < 8){

          if(j == i) soilHealth[i][j] = 2 * 15;

        }else if(j < 16){

          int offsetJ = j - 8;
          if(offsetJ == 0 || offsetJ == 3 || offsetJ == 4 || offsetJ == 7){
            if(i == 1 || i == 2 || i == 5 || i == 6){
              soilHealth[i][j] = 2 * 15;
            }
          }else{
            if(i == 0 || i == 3 || i == 4 || i == 7){
              soilHealth[i][j] = 2 * 15;
            }
          }

        }else{

          int offsetJ = j - 16;
          int stoneCount = (offsetJ + i) % 3;
          soilHealth[i][j] = (stoneCount + 1) * 15;

        }
      }
    }
  }

  // Initialize soidiers and their position
  soldierX = new float [6];
  soldierY = new float [6];
  for(int i = 0; i < soldierX.length; i ++){
    soldierX[i] = random(-SOIL_SIZE, width);
    soldierY[i] = SOIL_SIZE * (i*4+floor(random(4)));
   }
   
  // Initialize cabbages and their position
  cabbageX = new float [6];
  cabbageY = new float [6];
  for(int i = 0; i < cabbageX.length; i ++){
       cabbageX[i] = SOIL_SIZE *floor(random(SOIL_COL_COUNT));
       cabbageY[i] = SOIL_SIZE *(i*4+floor(random(4)));
      
   }
}

void draw() {

  switch (gameState) {

    case GAME_START: // Start Screen
    image(title, 0, 0);
    if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
      && START_BUTTON_X < mouseX
      && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
      && START_BUTTON_Y < mouseY) {

      image(startHovered, START_BUTTON_X, START_BUTTON_Y);
      if(mousePressed){
        gameState = GAME_RUN;
        mousePressed = false;
      }

    }else{

      image(startNormal, START_BUTTON_X, START_BUTTON_Y);

    }

    break;

    case GAME_RUN: // In-Game
    // Background
    image(bg, 0, 0);

    // Sun
      stroke(255,255,0);
      strokeWeight(5);
      fill(253,184,19);
      ellipse(590,50,120,120);

      // CAREFUL!
      // Because of how this translate value is calculated, the Y value of the ground level is actually 0
    pushMatrix();
    translate(0, max(SOIL_SIZE * -18, SOIL_SIZE * 1 - playerY));

    // Ground

    fill(124, 204, 25);
    noStroke();
    rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);

    // Soil

  for(int i = 0; i < SOIL_COL_COUNT; i++){
      for(int j = 0; j < SOIL_ROW_COUNT; j++){

        if(soilHealth[i][j] > 0){

          int soilColor = (int) (j / 4);
          int soilAlpha = (int) (min(5, ceil((float)soilHealth[i][j] / (15 / 5))) - 1);

          image(soils[soilColor][soilAlpha], i * SOIL_SIZE, j * SOIL_SIZE);

          if(soilHealth[i][j] > 15){
            int stoneSize = (int) (min(5, ceil(((float)soilHealth[i][j] - 15) / (15 / 5))) - 1);
            image(stones[0][stoneSize], i * SOIL_SIZE, j * SOIL_SIZE);
          }

          if(soilHealth[i][j] > 15 * 2){
            int stoneSize = (int) (min(5, ceil(((float)soilHealth[i][j] - 15 * 2) / (15 / 5))) - 1);
            image(stones[1][stoneSize], i * SOIL_SIZE, j * SOIL_SIZE);
          }

        }else{
          image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
        }

      }
    }

    // Soil background past layer 24
    for(int i = 0; i < SOIL_COL_COUNT; i++){
      for(int j = SOIL_ROW_COUNT; j < SOIL_ROW_COUNT + 4; j++){
        image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
      }
    }

    // Cabbages
    // > Remember to check if playerHealth is smaller than PLAYER_MAX_HEALTH!
    for(int i = 0; i < cabbageX.length; i++){
      image(cabbage,cabbageX[i], cabbageY[i]);
      
      if(playerHealth < PLAYER_MAX_HEALTH
        && cabbageX[i] + SOIL_SIZE > playerX    // r1 right edge past r2 left
        && cabbageX[i] < playerX + SOIL_SIZE    // r1 left edge past r2 right
        && cabbageY[i] + SOIL_SIZE > playerY    // r1 top edge past r2 bottom
        && cabbageY[i] < playerY + SOIL_SIZE) { // r1 bottom edge past r2 top

        playerHealth ++;
        cabbageX[i] = cabbageY[i] = -1000;

      }
   }
    // Groundhog

    PImage groundhogDisplay = groundhogIdle;

    // If player is not moving, we have to decide what player has to do next
    if(playerMoveTimer == 0){

      // HINT:
      // You can use playerCol and playerRow to get which soil player is currently on

      // Check if "player is NOT at the bottom AND the soil under the player is empty"
      // > If so, then force moving down by setting playerMoveDirection and playerMoveTimer (see downState part below for example)
      // > Else then determine player's action based on input state
      if((playerRow + 1 < SOIL_ROW_COUNT && soilHealth[playerCol][playerRow + 1] == 0) || playerRow + 1 >= SOIL_ROW_COUNT){

        groundhogDisplay = groundhogDown;
        playerMoveDirection = DOWN;
        playerMoveTimer = playerMoveDuration;

      }else{

      if(leftState){

        groundhogDisplay = groundhogLeft;

        // Check left boundary
        if(playerCol > 0){

          // HINT:
          // Check if "player is NOT above the ground AND there's soil on the left"
          // > If so, dig it and decrease its health
          // > Else then start moving (set playerMoveDirection and playerMoveTimer)
          if(playerRow >= 0 && soilHealth[playerCol - 1][playerRow] > 0){
             soilHealth[playerCol - 1][playerRow] --;
           }else{

          playerMoveDirection = LEFT;
          playerMoveTimer = playerMoveDuration;
         }
        }

      }else if(rightState){

        groundhogDisplay = groundhogRight;

        // Check right boundary
        if(playerCol < SOIL_COL_COUNT - 1){

          // HINT:
          // Check if "player is NOT above the ground AND there's soil on the right"
          // > If so, dig it and decrease its health
          // > Else then start moving (set playerMoveDirection and playerMoveTimer)
          if(playerRow >= 0 && soilHealth[playerCol + 1][playerRow] > 0){
              soilHealth[playerCol + 1][playerRow] --;
            }else{
          playerMoveDirection = RIGHT;
          playerMoveTimer = playerMoveDuration;
          }
        }

      }else if(downState){

        groundhogDisplay = groundhogDown;

        // Check bottom boundary

        // HINT:
        // We have already checked "player is NOT at the bottom AND the soil under the player is empty",
        // and since we can only get here when the above statement is false,
        // we only have to check again if "player is NOT at the bottom" to make sure there won't be out-of-bound exception
        if(playerRow < SOIL_ROW_COUNT - 1){
          soilHealth[playerCol][playerRow + 1] --;
          
          // > If so, dig it and decrease its health

          // For requirement #3:
          // Note that player never needs to move down as it will always fall automatically,
          // so the following 2 lines can be removed once you finish requirement #3
        }
        }
      }

    }else{
      // Draw image before moving to prevent offset
      switch(playerMoveDirection){
        case LEFT:  groundhogDisplay = groundhogLeft;  break;
        case RIGHT:  groundhogDisplay = groundhogRight;  break;
        case DOWN:  groundhogDisplay = groundhogDown;  break;
      }
    }


    // If player is now moving?
    // (Separated if-else so player can actually move as soon as an action starts)
    // (I don't think you have to change any of these)

    if(playerMoveTimer > 0){

      playerMoveTimer --;
      switch(playerMoveDirection){

        case LEFT:
        groundhogDisplay = groundhogLeft;
        if(playerMoveTimer == 0){
          playerCol--;
          playerX = SOIL_SIZE * playerCol;
        }else{
          playerX = (float(playerMoveTimer) / playerMoveDuration + playerCol - 1) * SOIL_SIZE;
        }
        break;

        case RIGHT:
        groundhogDisplay = groundhogRight;
        if(playerMoveTimer == 0){
          playerCol++;
          playerX = SOIL_SIZE * playerCol;
        }else{
          playerX = (1f - float(playerMoveTimer) / playerMoveDuration + playerCol) * SOIL_SIZE;
        }
        break;

        case DOWN:
        groundhogDisplay = groundhogDown;
        if(playerMoveTimer == 0){
          playerRow++;
          playerY = SOIL_SIZE * playerRow;
        }else{
          playerY = (1f - float(playerMoveTimer) / playerMoveDuration + playerRow) * SOIL_SIZE;
        }
        break;
      }

    }

    image(groundhogDisplay, playerX, playerY);

    // Soldiers
    for(int i = 0; i < soldierX.length; i++){
      image(soldier,soldierX[i] ,soldierY[i]);
      soldierX[i]+=2;
       if(soldierX[i] >= width) soldierX[i] = -SOIL_SIZE;
       if(soldierX[i] + SOIL_SIZE > playerX    // r1 right edge past r2 left
        && soldierX[i] < playerX + SOIL_SIZE    // r1 left edge past r2 right
        && soldierY[i] + SOIL_SIZE > playerY    // r1 top edge past r2 bottom
        && soldierY[i] < playerY + SOIL_SIZE) { // r1 bottom edge past r2 top

        playerHealth -= 1;

        if(playerHealth == 0){

          gameState = GAME_OVER;
          
          }else{

          playerX = PLAYER_INIT_X;
          playerY = PLAYER_INIT_Y;
          playerCol = (int) playerX / SOIL_SIZE;
          playerRow = (int) playerY / SOIL_SIZE;
          soilHealth[playerCol][playerRow + 1] = 15;
          playerMoveTimer = 0;
        }
        }
       }      


        
    // > Remember to stop player's moving! (reset playerMoveTimer)
    // > Remember to recalculate playerCol/playerRow when you reset playerX/playerY!
    // > Remember to reset the soil under player's original position!

    // Demo mode: Show the value of soilHealth on each soil
    // (DO NOT CHANGE THE CODE HERE!)

    if(demoMode){  

      fill(255);
      textSize(26);
      textAlign(LEFT, TOP);

      for(int i = 0; i < soilHealth.length; i++){
        for(int j = 0; j < soilHealth[i].length; j++){
          text(soilHealth[i][j], i * SOIL_SIZE, j * SOIL_SIZE);
        }
      }

    }

    popMatrix();

    // Health UI
    for (int i=0; i<playerHealth; i++){
    image(life,10 + i *70,10);
    }

    break;

    case GAME_OVER: // Gameover Screen
    image(gameover, 0, 0);
    
    if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
      && START_BUTTON_X < mouseX
      && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
      && START_BUTTON_Y < mouseY) {

      image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
      if(mousePressed){
        gameState = GAME_RUN;
        mousePressed = false;

        // Initialize player
        playerX = PLAYER_INIT_X;
        playerY = PLAYER_INIT_Y;
        playerCol = (int) (playerX / SOIL_SIZE);
        playerRow = (int) (playerY / SOIL_SIZE);
        playerMoveTimer = 0;
        playerHealth = 2;

        // Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
  
  int[] emptySoils = new int[SOIL_ROW_COUNT];
  
    for(int j = 0; j < SOIL_ROW_COUNT; j++){
    emptySoils[j] = ( j == 0 ) ? 0 : floor(random(1, 3));
  }
  
  for(int i = 0; i < soilHealth.length; i++){
    for (int j = 0; j < soilHealth[i].length; j++) {
       // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
    float randRes = random(SOIL_COL_COUNT - i);

      if(randRes < emptySoils[j]){

        soilHealth[i][j] = 0;
        emptySoils[j] --;

      }else{

        soilHealth[i][j] = 15;

        if(j < 8){

          if(j == i) soilHealth[i][j] = 2 * 15;

        }else if(j < 16){

          int offsetJ = j - 8;
          if(offsetJ == 0 || offsetJ == 3 || offsetJ == 4 || offsetJ == 7){
            if(i == 1 || i == 2 || i == 5 || i == 6){
              soilHealth[i][j] = 2 * 15;
            }
          }else{
            if(i == 0 || i == 3 || i == 4 || i == 7){
              soilHealth[i][j] = 2 * 15;
            }
          }

        }else{

          int offsetJ = j - 16;
          int stoneCount = (offsetJ + i) % 3;
          soilHealth[i][j] = (stoneCount + 1) * 15;

        }
      }
    }
  }

  // Initialize soidiers and their position
  soldierX = new float [6];
  soldierY = new float [6];
  for(int i = 0; i < soldierX.length; i ++){
    soldierX[i] = random(-SOIL_SIZE, width);
    soldierY[i] = SOIL_SIZE * (i*4+floor(random(4)));
   }
   
  // Initialize cabbages and their position
  cabbageX = new float [6];
  cabbageY = new float [6];
  for(int i = 0; i < cabbageX.length; i ++){
       cabbageX[i] = SOIL_SIZE *floor(random(8))+1;
       cabbageY[i] = SOIL_SIZE *(i*4+floor(random(4)));
      
   }
      }

    }else{

      image(restartNormal, START_BUTTON_X, START_BUTTON_Y);

    }
    break;
    
  }
}

void keyPressed(){
  if(key==CODED){
    switch(keyCode){
      case LEFT:
      leftState = true;
      break;
      case RIGHT:
      rightState = true;
      break;
      case DOWN:
      downState = true;
      break;
    }
  }else{
    if(key=='b'){
      // Press B to toggle demo mode
      demoMode = !demoMode;
    }
  }
}

void keyReleased(){
  if(key==CODED){
    switch(keyCode){
      case LEFT:
      leftState = false;
      break;
      case RIGHT:
      rightState = false;
      break;
      case DOWN:
      downState = false;
      break;
    }
  }
}
