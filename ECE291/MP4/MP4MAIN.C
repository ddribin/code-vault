extern int far INIT();
extern int far CLRSCR();
extern int far DISPLAY(int);
extern int far WTTIME();
extern int far SCROLL();
extern int far CHKBOT();
extern int far RESTORE();
extern int far MP4XIT();
extern int far TICKS;  
main()
    {
    int Error, N, flag ;
    INIT();		/* Initialize the 1Ch interrupt vector */
    flag = 0;		/* Clear the flag */
    while(flag == 0)    /* Always repeat this loop until MP4XIT called */
        {
        CLRSCR();	/* Clear the screen and set to yellow on red */ 
        printf("\n\nInput Number of Characters to Display on a Row: ");
        Error = scanf("%d", &N);    /* Read in the number of characters */
                                    /* Sets Error to 0 if non-numeric input */
        if ((N == 0) || (Error == 0)) /* Exit if 0 was entered or error */
            {
            RESTORE();		/* Restore the 1Ch interrupt vector */
            MP4XIT();		/* Exit to DOS */
            }
        if (N > 80 || N < 0) flag = 1;
        CLRSCR();		/* Clear the Screen */
        TICKS = 0;   		/* Set the global ticks variable to 0 */
        while(flag != 1)        /* If Flag = 1 then start again */
            {
            DISPLAY(N);		/* Display N random characters on top row */
            flag = WTTIME();	/* Check keyboard while waiting 1 second */
            if (flag == 2) 	/* Flag = 2 if user wants to exit */
                {
                RESTORE();	/* Restore the 1Ch interrupt vector */
                MP4XIT();	/* Exit to DOS */
                }
            SCROLL();		/* Scroll the screen down 1 row */
            flag = CHKBOT();    /* flag=1 if characters on bottom row */
            }
        flag = 0;		/* Clear the flag and start new game */
        }
    }
