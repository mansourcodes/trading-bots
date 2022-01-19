//+------------------------------------------------------------------+
//|                                                          buy.mq4 |
//|                                                 Mansour Alnassre |
//|                                     https://www.mansourcodes.com |
//+------------------------------------------------------------------+
#property strict




//+------------------------------------------------------------------+
//| Settings                                  |
//+------------------------------------------------------------------+

double lotSize = 0.1;

bool disableStopLoss = false;
bool activeKijunStopLoss = false;
int stoplossPips = 100;

int takeprofitPips = 20;

double NumberOfCandle = 20;

bool windowFlag = true;


//+------------------------------------------------------------------+
//| Init                                  |
//+------------------------------------------------------------------+

int MagicNumber = 123123;
int currentOrderTicket = -1;
double currentCandleOpenPrice =0;




//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void buyMonitor()
  {
   //Alert("-----------------------------");
   //Alert("-----------------------------");




   run();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void run()
  {





   if(!newCandle())
     {
      return;
     }

   if(OrdersTotal() > 0)
     {
      updateBuyOrder();
      closeBuyOrder();
     }

   if(
      1

// miger
      && noOrderBuyOpen()
      && isRedUpoveBlue()
      && isFrontKumoBlue()
      && isCandleUpoveBlue()
      && isCandleUpoveKumo()
      && countKumoCrosedToXCandle(10, 1)

// optional
//      && countRedCrosedBlue(4)
//      && countBlackUpoveCandles() > 1


//      && isRedUpoveKumo()
//      && isRedCrosedBlue()         //------ bad
      && isCurrentKumoPink()

      && windowFlag == true
   )
     {

      openBuyOrder();
      windowFlag = false;
     }


   if(!isCandleUpoveKumo())
     {
      windowFlag = true;
     }
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeBuyOrder()
  {


   if(
      0
      || isKinjunTrendUp(4)
//      || isCandleUpoveKumo()
//      || isCandleInsideKumo()
//      || isFrontKumoBlue()
// && isCurrentKumoPink() // current blue
//      && countKumoCrosedToXCandle(0) <= 1  // clean kumo (pink to blue || blue to end)
   )
     {
      //Alert("[Close][Holded] kumo from current to end is blue ");
      return;
     }


   if(
      1
      && !isRedUpoveBlue()   // is blue under red
   )
     {

      OrderSelect(currentOrderTicket,SELECT_BY_TICKET);

      OrderClose(
         currentOrderTicket,      // ticket
         OrderLots(),        // volume
         Ask,       // close price
         100,    // slippage
         clrBlue  // color
      );


      currentOrderTicket = -1;
      //Alert("[Close] end of red is above blue: candle index: ");
     }

  }
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countBlackUpoveCandles()
  {

   double high = 0;
   double blockLine = 0;
   double counter = 0;
   int shift = 26;

   double lastCadleId = shift+NumberOfCandle;
   int index = 0;


   for(index =shift ; index < lastCadleId ; index++)
     {
      blockLine =iIchimoku(_Symbol,0,9,26,52,MODE_CHIKOUSPAN,index);

      if(blockLine >  High[index])
        {
         counter++;
        }
      else
        {
         break;
        }
     }


   //Alert("[PASS] black upove candle "+ counter);
   return counter;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isRedCrosedBlue()
  {

   double back_redLine = 0;
   double back_blueLine = 0;

   double shift = 1;
   double lastCadleId = shift+NumberOfCandle;


   back_redLine =iIchimoku(_Symbol,0,9,26,52,MODE_TENKANSEN,lastCadleId);
   back_blueLine =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,lastCadleId);

   if(back_redLine  <  back_blueLine)
     {
      //Alert("[PASS] begin of red is under blue: candle index: "+ lastCadleId);
     }
   else
     {
      //Alert("[FAIL] begin of red and blue not match: candle index: "+ lastCadleId);
      return false;
     }



   //Alert("[PASS] red upove blue ");
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isRedUpoveBlue()
  {

   double front_redLine = 0;
   double front_blueLine = 0;

   front_redLine =iIchimoku(_Symbol,0,9,26,52,MODE_TENKANSEN,0);
   front_blueLine =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);

   if(front_redLine >  front_blueLine)
     {
      //Alert("[PASS] end of red is above blue: candle index: "+ 0);
     }
   else
     {
      //Alert("[FAIL] end of red and blue not match: candle index: " + 0);
      return false;
     }

   //Alert("[PASS] red crossed blue ");
   return true;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isRedUpoveKumo()
  {

   double skyBlueLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,0);
   double skyPinkLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,0);
   double front_redLine =iIchimoku(_Symbol,0,9,26,52,MODE_TENKANSEN,1);


   if(
      1
      && front_redLine > skyBlueLine_current
      && front_redLine > skyPinkLine_current
   )
     {

      //Alert("[PASS] red Upove kumo");
      return true;
     }



   //Alert("[FAIL] not red Upove kumo");
   return false;


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool countRedCrosedBlue(int passNumber)
  {


   double redLine = 0;
   double blueLine = 0;
   double counterCross = 0;
   double shift = 1;
   double lastCadleId = shift+NumberOfCandle;
   int index = 0;
   bool croseFlag = false;


   for(index =shift ; index < lastCadleId ; index++)
     {
      redLine =iIchimoku(_Symbol,0,9,26,52,MODE_TENKANSEN,index);
      blueLine =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,index);

      if(redLine >  blueLine && croseFlag)
        {
         counterCross++;
         ObjectCreate(0,"Vline:"+Time[index+1],OBJ_VLINE,0,Time[index],0);
         croseFlag = false;
        }
      else
         if(redLine <  blueLine && !croseFlag)
           {
            counterCross++;
            ObjectCreate(0,"Vline:"+Time[index+1],OBJ_VLINE,0,Time[index],0);
            croseFlag = true;
           }
     }


   if(counterCross <= passNumber)
     {

      //Alert("[PASS] red crossed blue  !#"+counterCross + "  less then" + passNumber);
      return true;
     }
   else
     {

      //Alert("[Fail] red crossed blue  TO MANY !#"+counterCross + "NOT  less then" + passNumber);
      return false;
     }


  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isFrontKumoBlue()
  {

   double front_skykumoLine = 0;
   double front_pinkkumoLine = 0;

   double shift = -26;

   front_skykumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,shift);
   front_pinkkumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,shift);


   if(front_skykumoLine >  front_pinkkumoLine)
     {
      //Alert("[PASS] front kumo is blue ");
      return true;
     }



   //Alert("[FAIL] front kumo NOT blue "+ shift);
   return false;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCurrentKumoPink()
  {



   double current_skykumoLine = 0;
   double current_pinkkumoLine = 0;

   current_skykumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,0);
   current_pinkkumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,0);


   if(current_skykumoLine <  current_pinkkumoLine)
     {
      //Alert("[PASS] current candle kumo is pink : "+ 0);
      return true;
     }


   //Alert("[FAIL] current candle kumo NOT pink "+ 0);
   return false;


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countKumoCrosedToXCandle(int lastIndexCandle, int minValidCross)
  {


   double skykumoLine = 0;
   double pinkkumoLine = 0;

   double counterCross = 0;
   double shift = -26;
   int lastCadleId =  shift;
   int index = 0;
   bool croseFlag = true;


   int firstCandleUpoveKumo = lastIndexCandle;

   for(index =shift ; index < firstCandleUpoveKumo ; index++)
     {

      skykumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,index);
      pinkkumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,index);

      if(skykumoLine <  pinkkumoLine && croseFlag)
        {
         counterCross++;
         if(index > 0)
           {
            ObjectCreate(0,"Vline:"+Time[index+1],OBJ_VLINE,0,Time[index],0);
           }
         croseFlag = false;
        }
      else
         if(skykumoLine >  pinkkumoLine && !croseFlag)
           {
            counterCross++;
            if(index > 0)
              {
               ObjectCreate(0,"Vline:"+Time[index+1],OBJ_VLINE,0,Time[index],0);
              }
            croseFlag = true;
           }
     }



   if(counterCross <= minValidCross)
     {
      //Alert("[PASS] kumo has crossed less then "+ minValidCross);
      return true;
     }
   else
     {

      //Alert("[Fail] kumo has crossed TOO MANY  #"+ counterCross);
     }

   return false;

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int isCandleUpoveKumo()
  {



   double skyBlueLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,0);
   double skyPinkLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,0);
   double open_current = Open[0];


   if(
      1
      && open_current >skyBlueLine_current
      && open_current >skyPinkLine_current
   )
     {

      //Alert("[PASS] candle Upove kumo");
      return true;
     }



   //Alert("[FAIL] not candle Upove kumo");
   return false;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCandleUpoveBlue()
  {



   double front_blueLine =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);
   double open_current = Open[0];


   if(
      open_current >front_blueLine
   )
     {

      //Alert("[PASS] candle Upove blue");
      return true;
     }



   //Alert("[FAIL] not candle Upove blue");
   return false;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCandleInsideKumo()
  {


   double skyBlueLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,0);
   double skyPinkLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,0);
   double open_current = Open[0];


   if(
      1
      && open_current >skyBlueLine_current
      && open_current <skyPinkLine_current
   )
     {

      //Alert("[PASS] candle inside kumo");
      return true;
     }
   else
      if(
         1
         && open_current <skyBlueLine_current
         && open_current >skyPinkLine_current
      )
        {

         //Alert("[PASS] candle inside kumo");
         return true;
        }



   //Alert("[FAIL] NOT candle inside kumo");
   return false;

  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openBuyOrder()
  {


   double takeprofit = Ask+takeprofitPips*10*_Point;

   currentOrderTicket = OrderSend(
                           Symbol(),               // symbol
                           OP_BUY,                 // operation
                           lotSize,                   // volume
                           Ask,                    // price
                           3,                       // slippage
                           Ask-stoplossPips*10*_Point, //Ask-100*_Point,                      // stop loss
                           takeprofit, //Ask+10*_Point,                      // take profit
                           "Orderha: "+ MagicNumber,              // comment
                           MagicNumber,               // magic number
                           0,                      // pending order expiration
                           clrBlue                 // color
                        );


   if(currentOrderTicket < 0)
     {
      //Alert("OrderSend failed with error #",GetLastError());
     }
   else{}
      //Alert("OrderSend placed successfully");

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void updateBuyOrder()
  {



   if(OrderSelect(currentOrderTicket,SELECT_BY_TICKET) == false)
     {
      return;
     }

   bool updated =  OrderModify(
                      currentOrderTicket,      // ticket
                      0,       // price
                      currentStoploss(),    // stop loss
                      OrderTakeProfit(),  // take profit
                      0,  // expiration
                      clrBlue  // color
                   );


   if(!updated)
     {
      //Alert("order failed with error #",GetLastError());
     }
   else{}
      //Alert("Order update successfully");


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool noOrderBuyOpen()
  {
   int pos;
   for(pos =0 ; pos < OrdersTotal() ; pos++)
     {
      OrderSelect(pos,SELECT_BY_POS);
      if(OrderSelect(pos,SELECT_BY_POS) == true)
        {
         if(OrderMagicNumber() == MagicNumber)
           {
            //Alert("[FAIL] you  can open order");
            return false;
           }
        }
     }


   //Alert("[PASS] you  can open order");
   return true;

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double currentStoploss()
  {

   if(disableStopLoss == true)
     {
      return 0;
     }

   double stoploss_pips ;
   double stoploss_kij  =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);
   OrderSelect(currentOrderTicket,SELECT_BY_TICKET);


   if(OrderProfit() > 0 &&  activeKijunStopLoss)
     {

      double pips = 30;
      stoploss_pips = Ask-pips*10*_Point;

      if(stoploss_pips < stoploss_kij)
        {
         return stoploss_pips;
        }
      else
        {
         return stoploss_kij;
        }

     }
   else
     {

      stoploss_pips = OrderOpenPrice()-stoplossPips*10*_Point;


      if(activeKijunStopLoss == false)
        {
         return stoploss_pips;
        }


      if(stoploss_pips < stoploss_kij)
        {
         return stoploss_pips;
        }
      else
        {
         return stoploss_kij;
        }
     }

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool newCandle()
  {

   if(currentCandleOpenPrice == Open[0])
     {
      return false;
     }
   else
     {
      currentCandleOpenPrice = Open[0];
      return true;
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isKinjunTrendUp(int allowCounter)
  {

   double kij_prev,kij_current;

   OrderSelect(currentOrderTicket,SELECT_BY_TICKET);

   int OrderIndex =  iBarShift(
                        Symbol(),          // symbol
                        0,       // timeframe
                        OrderOpenTime(),            // time
                        false      // mode
                     );




   kij_current =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);
   kij_prev =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,OrderIndex);


   double pipsDef =  kij_current - kij_prev;
   if(pipsDef < 0)
     {
      return false;
     }


   int pos;
   for(pos=0 ; pos < OrderIndex ; pos++)
     {

      kij_current =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,pos);
      kij_prev =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,pos+1);

      if(kij_current >= kij_prev)
        {
         // continue;
        }
      else
        {
         allowCounter--;
         Comment("Kinjun Trend up : allowCounter: "+ allowCounter);
         if(allowCounter <= 0)
           {
            Comment("Kinjun Trend Down !!!!");
            return false;

           }
        }

     }

   return true;


  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+