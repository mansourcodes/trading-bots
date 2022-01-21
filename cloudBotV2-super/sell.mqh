//+------------------------------------------------------------------+
//|                                                         Sell.mq4 |
//|                                                 Mansour Alnassre |
//|                                     https://www.mansourcodes.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Settings                                  |
//+------------------------------------------------------------------+

double sell_lotSize = 0.1;

bool sell_disableStopLoss = false;
bool sell_activeKijunStopLoss = false;
int sell_stoplossPips = 25;

int sell_takeprofitPips = 25;

double sell_NumberOfCandle = 20;

bool sell_windowFlag = true;

int kumoBeforCandel = 40;


//+------------------------------------------------------------------+
//| Init                                  |
//+------------------------------------------------------------------+

int sell_MagicNumber = 200000;
int sell_currentOrderTicket = -1;
double sell_currentCandleOpenPrice =0;




//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void sellMonitor()
  {



   runSell();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void runSell()
  {





   if(!newSellCandle())
     {
      return;
     }

   if(OrdersTotal() > 0)
     {
      updateSellOrder();
//closeSellOrder();
     }

   if(
      1

// miger
      && noOrderSellOpen()
      && isRedBelowBlue()
      && isFrontKumoPink()
      && isCandleBelowBlue()
      && isCandleBelowKumo()
      && countKumoCrosedToXCandleDown(kumoBeforCandel, 1)

// optional
//      && countRedCrosedBlueDown(4)
//      && countBlackBelowCandles() > 1


//      && isRedBelowKumo()
//      && isRedCrosedBlueDown()         //------ bad
//      && isCurrentKumoBlue()

      && sell_windowFlag == true
   )
     {

      openSellOrder();
      sell_windowFlag = false;
     }


   if(!isCandleBelowKumo())
     {
      sell_windowFlag = true;
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeSellOrder()
  {

   if(isCandleInsideKumoSell())
     {
     // closeCurrentSellOrder();
     }

   if(isKinjuStreetForXCandle(6))
     {
  //    closeCurrentSellOrder();
     }


   if(
      0
      || isKinjunTrendDown(6)
//      || isCandleBelowKumo()
//      || isCandleInsideKumoSell()
//      || isFrontKumoPink()
//      && isCurrentKumoBlue() // current blue
//      && countKumoCrosedToXCandleDown(0, 1)  // clean kumo (pink to blue || blue to end)

   )
     {
      //Alert("[Close][Holded] kumo from current to end is blue ");
      return;
     }




   if(!isRedBelowBlue())
     {
      closeCurrentSellOrder();
     }

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeCurrentSellOrder()
  {

   OrderSelect(sell_currentOrderTicket,SELECT_BY_TICKET);

   OrderClose(
      sell_currentOrderTicket,      // ticket
      OrderLots(),        // volume
      Bid,       // close price
      100,    // slippage
      clrBlue  // color
   );


   sell_currentOrderTicket = -1;
   //Alert("[Close] end of red is above blue: candle index: ");

  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countBlackBelowCandles()
  {

   double high = 0;
   double blockLine = 0;
   double counter = 0;
   int shift = 26;

   double lastCadleId = shift+sell_NumberOfCandle;
   int index = 0;


   for(index =shift ; index < lastCadleId ; index++)
     {
      blockLine =iIchimoku(_Symbol,0,9,26,52,MODE_CHIKOUSPAN,index);

      if(blockLine <  Low[index])
        {
         counter++;
        }
      else
        {
         break;
        }
     }


   //Alert("[PASS] black below candle "+ counter);
   return counter;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isRedCrosedBlueDown()
  {

   double back_redLine = 0;
   double back_blueLine = 0;

   double shift = 1;
   double lastCadleId = shift+sell_NumberOfCandle;


   back_redLine =iIchimoku(_Symbol,0,9,26,52,MODE_TENKANSEN,lastCadleId);
   back_blueLine =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,lastCadleId);

   if(back_redLine  >  back_blueLine)
     {
      //Alert("[PASS] begin of red is upove blue: candle index: "+ lastCadleId);
     }
   else
     {
      //Alert("[FAIL] begin of red and blue not match: candle index: "+ lastCadleId);
      return false;
     }



   //Alert("[PASS] red below blue ");
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isRedBelowBlue()
  {

   double front_redLine = 0;
   double front_blueLine = 0;

   front_redLine =iIchimoku(_Symbol,0,9,26,52,MODE_TENKANSEN,0);
   front_blueLine =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);

   if(front_redLine <  front_blueLine)
     {
      //Alert("[PASS] end of red is Below blue: candle index: "+ 0);
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
bool isRedBelowKumo()
  {

   double skyBlueLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,0);
   double skyPinkLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,0);
   double front_redLine =iIchimoku(_Symbol,0,9,26,52,MODE_TENKANSEN,1);


   if(
      1
      && front_redLine < skyBlueLine_current
      && front_redLine < skyPinkLine_current
   )
     {

      //Alert("[PASS] red Below kumo");
      return true;
     }



   //Alert("[FAIL] not red Below kumo");
   return false;


  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool countRedCrosedBlueDown(int passNumber)
  {


   double redLine = 0;
   double blueLine = 0;
   double counterCross = 0;
   double shift = 1;
   double lastCadleId = shift+sell_NumberOfCandle;
   int index = 0;
   bool croseFlag = true;


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
bool isFrontKumoPink()
  {

   double front_skykumoLine = 0;
   double front_pinkkumoLine = 0;

   double shift = -26;

   front_skykumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,shift);
   front_pinkkumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,shift);


   if(front_skykumoLine <  front_pinkkumoLine)
     {
      //Alert("[PASS] front kumo is pink ");
      return true;
     }



   //Alert("[FAIL] front kumo NOT pink "+ shift);
   return false;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCurrentKumoBlue()
  {



   double current_skykumoLine = 0;
   double current_pinkkumoLine = 0;

   current_skykumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,0);
   current_pinkkumoLine =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,0);


   if(current_skykumoLine >  current_pinkkumoLine)
     {
      //Alert("[PASS] current candle kumo is blue : "+ 0);
      return true;
     }


   //Alert("[FAIL] current candle kumo NOT blue "+ 0);
   return false;


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int countKumoCrosedToXCandleDown(int lastIndexCandle, int minValidCross)
  {


   double skykumoLine = 0;
   double pinkkumoLine = 0;

   double counterCross = 0;
   double shift = -26;
   int lastCadleId =  shift;
   int index = 0;
   bool croseFlag = false;


   int firstCandleBelowKumo = lastIndexCandle;

   for(index =shift ; index < firstCandleBelowKumo ; index++)
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
int isCandleBelowKumo()
  {



   double skyBlueLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANA,0);
   double skyPinkLine_current =iIchimoku(_Symbol,0,9,26,52,MODE_SENKOUSPANB,0);


   if(
      1
      && Open[0] <skyBlueLine_current
      && Open[0] <skyPinkLine_current
   )
     {

      //Alert("[PASS] candle Below kumo");
      return true;
     }



   //Alert("[FAIL] not candle Below kumo");
   return false;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCandleBelowBlue()
  {



   double front_blueLine =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);
   double open_current = Open[0];


   if(
      open_current <front_blueLine
   )
     {

      //Alert("[PASS] candle Below blue");
      return true;
     }



   //Alert("[FAIL] not candle Below blue");
   return false;

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isCandleInsideKumoSell()
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
void openSellOrder()
  {


   double takeprofit = Bid-sell_takeprofitPips*10*_Point;

   sell_currentOrderTicket = OrderSend(
                                Symbol(),               // symbol
                                OP_SELL,                 // operation
                                sell_lotSize,                   // volume
                                Bid,                    // price
                                3,                       // slippage
                                Bid+sell_stoplossPips*10*_Point, //Bid+100*_Point,                      // stop loss
                                takeprofit, //Bid+10*_Point,                      // take profit
                                "Order Sell: "+ sell_MagicNumber,              // comment
                                sell_MagicNumber,               // magic number
                                0,                      // pending order expiration
                                clrPink                 // color
                             );


   if(sell_currentOrderTicket < 0)
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
void updateSellOrder()
  {

   if(OrderSelect(sell_currentOrderTicket,SELECT_BY_TICKET) == false)
     {
      return;
     }

   bool updated =  OrderModify(
                      sell_currentOrderTicket,      // ticket
                      0,       // price
                      currentSellStoploss(),    // stop loss
                      OrderTakeProfit(),  // take profit
                      0,  // expiration
                      clrPink  // color
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
bool noOrderSellOpen()
  {
   int pos;
   for(pos =0 ; pos < OrdersTotal() ; pos++)
     {
      OrderSelect(pos,SELECT_BY_POS);
      if(OrderSelect(pos,SELECT_BY_POS) == true)
        {
         if(OrderMagicNumber() == sell_MagicNumber)
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
double currentSellStoploss()
  {

   if(sell_disableStopLoss == true)
     {
      return 0;
     }

   double stoploss_pips ;
   double stoploss_kij  =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);
   OrderSelect(sell_currentOrderTicket,SELECT_BY_TICKET);


   if(OrderProfit() > 0 &&  sell_activeKijunStopLoss)
     {

      double pips = 30;
      stoploss_pips = Bid+pips*10*_Point;

      if(stoploss_pips > stoploss_kij)
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

      stoploss_pips = OrderOpenPrice()+sell_stoplossPips*10*_Point;


      if(sell_activeKijunStopLoss == false)
        {
         return stoploss_pips;
        }


      if(stoploss_pips > stoploss_kij)
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
bool newSellCandle()
  {

   if(sell_currentCandleOpenPrice == Open[0])
     {

      return false;
     }
   else
     {
      //Alert("[Pass] newSellCandle " + Open[0]);
      sell_currentCandleOpenPrice = Open[0];
      return true;
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isKinjunTrendDown(int allowCounter)
  {

   double kij_prev,kij_current;

   OrderSelect(sell_currentOrderTicket,SELECT_BY_TICKET);

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

      if(kij_current <= kij_prev)
        {
         // continue;
        }
      else
        {
         allowCounter--;
         Comment("Kinjun Trend Down : allowCounter: "+ allowCounter);
         if(allowCounter <= 0)
           {
            Comment("Kinjun Trend up !!!!");
            return false;

           }
        }

     }

   return true;


  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isKinjuStreetForXCandle(int candleAllowCount)
  {


   double kij_prev,kij_current;
   int pos;


   for(pos=0 ; pos <= candleAllowCount ; pos++)
     {

      kij_current =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,pos);
      kij_prev =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,pos+1);

      if(kij_current == kij_prev)
        {
         //--
         
        }
      else
        {
         return false;
        }
     }
   //Alert("[fail]  to many equal blue line ");
   return true;

  }
//+------------------------------------------------------------------+
