//+------------------------------------------------------------------+
//|                                                    clouldBot.mq4 |
//|                                                 Mansour Alnassre |
//|                                     https://www.mansourcodes.com |
//+------------------------------------------------------------------+
#property copyright "Mansour Alnassre"
#property link      "https://www.mansourcodes.com"
#property version   "2.00"
#property strict


#include "buy.mqh"
#include "sell.mqh"





//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   buyMonitor(); 
   sellMonitor();
   
   
   updateLotSize();

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+



//+------------------------------------------------------------------+

void updateLotSize(){


   double balance = AccountBalance();
   double lot = (0.3 * balance) / (250);
   
   lot = NormalizeDouble(lot,2);
   Alert("balance : " + balance);
   Alert(lot);
   
   //lot = 13;

   lotSize = lot/2;
   sell_lotSize = lot/2;

}