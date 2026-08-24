#include "comment.header"

/* $Id: smgcom.h,v 1.3 1997/07/06 19:38:28 ergo Exp $ */

/*
 * $Log: smgcom.h,v $
 * Revision 1.3  1997/07/06 19:38:28  ergo
 * actual version
 *
 * Revision 1.2  1997/05/04 18:57:24  ergo
 * added time control for moves
 *
 */

struct {
  char str[3];
  Token val;
} commands[] = {
  {"W", t_White},          /*  White         */
  {"B", t_Black},          /*  Black         */
  {"C", t_Comment},        /*  Comment       */
  {"AW", t_AddWhite},      /*  AddWhite      */
  {"AB", t_AddBlack},      /*  AddBlack      */
  {"L", t_Letter},         /*  Letter        */
  {"M", t_Mark},           /*  Mark          */
  {"AE", t_AddEmpty},      /*  AddEmpty      */
  {"N", t_Name},           /*  Name          */
  {"PL", t_Player},        /*  PLayer        */
  {"SZ", t_Size},          /*  SiZe          */
  {"HA", t_Handicap},      /*  HAndicap      */
  {"PB", t_PlayerBlack},   /*  PlayerBlack   */
  {"PW", t_PlayerWhite},   /*  PlayerWhite   */
  {"WR", t_WhiteRank},     /*  WhiteRank     */
  {"BR", t_BlackRank},     /*  BlackRank     */
  {"GN", t_GameName},      /*  GameName      */
  {"EV", t_Event},         /*  EVent         */
  {"RO", t_Round},         /*  ROund         */
  {"DT", t_Date},          /*  DaTe          */
  {"PC", t_Place},         /*  PlaCe         */
  {"TM", t_TimeLimit},     /*  TiMe limit    */
  {"RE", t_Result},        /*  REsult        */
  {"GC", t_GameComment},   /*  Game Comment  */
  {"SO", t_Source},        /*  SOurce        */
  {"US", t_User},          /*  USer          */
  {"KM", t_Komi}};         /*  KoMi          */

