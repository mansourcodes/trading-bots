//+------------------------------------------------------------------+
//|                                                         main.mq4 |
//|                                                 Mansour Alnasser |
//|                                     https://www.mansourcodes.com |
//+------------------------------------------------------------------+
#property copyright "Mansour Alnasser"
#property link      "https://www.mansourcodes.com"
#property version   "1.00"
#property strict



//+------------------------------------------------------------------+
//| Settings                                  |
//+------------------------------------------------------------------+

double lotSize = 0.03;
double targetedProfit = 0.3;
int totalOpenOrders = 20;
double RsiDeffMargen = 1;


int op,magic = 123456,lessTargetFactor=0.01;
double price,Slippage,currentCandleOpenPrice;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   loopOrders();


   if(isNewCandle())
     {
      if(OrdersTotal() <= totalOpenOrders)
        {
         openOrder();
        }
     }




//ExpertRemove();

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double spread()
  {
   return MarketInfo(_Symbol,MODE_SPREAD);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RsiStatus(ENUM_TIMEFRAMES timeframe)
  {

   double currentRSI = iRSI(NULL,timeframe,14,PRICE_CLOSE,0);
   double _1_RSI = iRSI(NULL,timeframe,14,PRICE_CLOSE,1);
   double deff = currentRSI - _1_RSI;

   if(deff >= RsiDeffMargen && currentRSI < 50)
     {
      return OP_BUY;
     }

   if(deff <= (RsiDeffMargen * -1) && currentRSI > 50)
     {
      return OP_SELL;
     }

   return -1;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loopOrders()
  {

// Normalization of the slippage.
   if(Digits==3 || Digits==5)
     {
      Slippage=Slippage*10;
     }

//OPEN ORDERS EXIST
   if(OrdersTotal() > 0)
     {
      //LOOK THROUGH ALL OPEN ORDERS
      for(int order_counter = 0; order_counter < OrdersTotal(); order_counter ++)
        {
         //CURRENT OPEN ORDER MATCHES CURRENT SYMBOL
         if(OrderSelect(order_counter, SELECT_BY_POS, MODE_TRADES) == true && OrderSymbol() == Symbol())
           {

            checkOrder();

           }
        }
     }

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int forceCloseOrder()
  {

// We define the close price, which depends on the type of order.
// We retrieve the price for the instrument of the order using MarketInfo(OrderSymbol(), MODE_BID) or MODE_ASK.
// And we normalize the price found.
   double ClosePrice;
   RefreshRates();
   if(OrderType()==OP_BUY)
      ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),Digits);
   if(OrderType()==OP_SELL)
      ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),Digits);

// If the order is closed correctly, we increment the counter of closed orders.
// If the order fails to be closed, we print the error.
   if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,Slippage,CLR_NONE))
     {
      return 1;
     }
   else
     {
      Print("Order failed to close with error - ",GetLastError());
      return 0;
     }

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openOrder()
  {
   op = NULL;

   int op_m1 = RsiStatus(PERIOD_M1);
   int op_m15 = RsiStatus(PERIOD_M15);

   if(op_m1 == -1 || op_m15 == -1)
     {
      reset();
      return;
     }


   if(op_m15 == op_m1)
     {
      op = op_m1;
     }
   else
     {
      Alert("Not Clear direction");
      reset();
      return;
     }

//*/

   if(op == OP_BUY)
     {
      price = Ask;
     }
   if(op == OP_SELL)
     {
      price = Bid;
     }



// if(trendKijunsen() != op  && trendKijunsen() != NULL)
//   {
//    reset();
//  return;
//   }

   OrderSend(
      _Symbol,              // symbol
      op,                 // operation
      lotSize,              // volume
      price,               // pric
      3,            // slippage
      0,            // stop loss
      0,          // take profit
      "jjv1",        // comment
      magic             // magic number
   );



   if(op == OP_BUY)
     {
      Alert("New Order Opened: BUY");
     }
   else
     {
      if(op == OP_SELL)
        {
         Alert("New Order Opened: SELL");
        }
     }

  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkOrder()
  {


   if(OrderProfit() > targetedProfit - lessTargetFactor)
     {

      forceCloseOrder();
      Alert("Wooooow : Profit taken");

     }
   else
     {
      Alert("order profit : "+OrderProfit());

      double gap = TimeCurrent() - OrderOpenTime() ;
      double minutes = gap/60;

      if(
         OrderProfit() < (0.5 * 80 * -1)
         && minutes > 15
      )
        {
         forceCloseOrder();
        }
     }

   lessTargetFactor += 0.01;

  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewCandle()
  {

   if(currentCandleOpenPrice == Open[0])
     {

      return false;
     }
   else
     {
      //Alert("[Pass] newSellCandle " + Open[0]);
      lessTargetFactor = 0.01;
      currentCandleOpenPrice = Open[0];
      return true;
     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int trendKijunsen()
  {

   double kij_current =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,0);
   double kij_pr_1 =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,1);
   double kij_pr_2 =iIchimoku(_Symbol,0,9,26,52,MODE_KIJUNSEN,2);

   if(kij_current == kij_pr_1 && kij_pr_1 == kij_pr_2)
     {
      return NULL;
     }

   if(kij_current >= kij_pr_1 && kij_pr_1 >= kij_pr_2)
     {
      return OP_BUY;
     }

   if(kij_current <= kij_pr_1 && kij_pr_1 <= kij_pr_2)
     {
      return OP_SELL;
     }

   return NULL;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void reset()
  {

// reset curent candle
   currentCandleOpenPrice = 0;
   return;

  }
//+------------------------------------------------------------------+
