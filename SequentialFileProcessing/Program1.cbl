       program-id. Program1 as "SequentialFileProcessing.Program1".

       environment division.
       input-output section.
       file-control.       select payroll-trans
                           assign to "C:\a\exercise9\input1.txt"
                           organization is line sequential.

                           select payroll-master
                           assign to "C:\a\exercise9\input2.txt"
                           organization is line sequential.

                           select updated-payroll-master
                           assign to "C:\a\exercise9\output1.txt".

                           select control-listing
                           assign to "C:\a\exercise9\output2.txt".

       data division.
       file section.

       fd  payroll-trans
       record contains 80 characters.
       01  payroll-trans-record.
           05  employee-no-trans       picture x(5).
           05  filler                  picture x(24).
           05  annual-salary-trans     picture 9(6).
           05  filler                  picture x(45).

       fd  payroll-master
       record contains 80 characters.  
       01  payroll-master-record.
           05  employee-no-master      picture x(5).
           05  filler                  picture x(24).
           05  annual-salary-master    picture 9(6).
           05  filler                  picture x(45).

       fd  updated-payroll-master
       record contains 80 characters.  
       01  updated-payroll-master-record.
           05  employee-no-uptd        picture x(5).
           05  filler                  picture x(24).
           05  annual-salary-uptd      picture 9(6).
           05  filler                  picture x(45).

       fd  control-listing.
       01  print-rec               picture x(99).

       working-storage section.
       
       01  hl-header-1.
           05      picture x(30) value spaces.
           05      picture x(35) value "CONTROL LISTING FOR PAYROLL UPDATE".
           05      picture x(4) value spaces.
           05  date-field-format    picture X(10).
           05      picture xxx value spaces.
           05      picture x(4) value "PAGE".
           05      picture x value spaces.
           05  page-no              picture 99.
           05      picture x(11) value spaces.

       01  date-field.
           05  year-field          picture 9(4).
           05  month-field         picture 9(2).
           05  day-field           picture 9(2).

       01  hl-header-2.
           05      picture x(10) value spaces.
           05      picture x(12) value "EMPLOYEE NO.".
           05      picture x(8) value spaces.
           05      picture x(22) value "PREVIOUS ANNUAL SALARY".
           05      picture xx value spaces.
           05      picture x(17) value "NEW ANNUAL SALARY".
           05      picture x(4) value spaces.
           05      picture x(12) value "ACTION TAKEN".
           05      picture x(12) value spaces.

       01  payroll-trans-out.
           05                      picture x(12) value spaces.
           05  employee-no-out     picture x(5).
           05                      picture x(13) value spaces.
           05  prev-annual-salary-out  picture $ZZZ,ZZZ.99.
           05                      picture x(13) value spaces.
           05  new-annual-salary-out   picture $ZZZ,ZZZ.99.
           05                      picture x(8) value spaces.
           05  type-of-action-taken    picture x(16).
           05                      picture x(10) value spaces.
       
        01  ws-old-master-eof  picture x value 'N'.                         
        01  ws-transfile-eof   picture x value 'N'. 

       PROCEDURE DIVISION.                                              
       100-main-module.

           display 'PROGRAM STARTED'                                   
           perform 200-initialization                                  
           perform 400-read-old-master                                 
           perform 500-read-transfile                                  
           perform 300-compare                                         
           until ws-old-master-eof = 'Y' and ws-transfile-eof = 'Y'
             
           stop run.

       200-initialization.

            open input payroll-master                                       
            open output updated-payroll-master                                      
            open input payroll-trans
            open output control-listing

            move spaces to print-rec

            move function current-date to date-field
            move day-field & "/" & month-field & "/" & year-field 
               to date-field-format

            set page-no to 1

            write print-rec from hl-header-1 after advancing 4 lines
            write print-rec from hl-header-2 after advancing 2 lines.

       300-compare.                                                    

           display 'COMPARING RECORDS.'
           evaluate true                                               
               when employee-no-trans < employee-no-master                            
                    perform 600-new-acct                                
               when employee-no-trans = employee-no-master                           
                    perform 700-update-acct                                 
               when employee-no-trans > employee-no-master                            
                    perform 800-no-update                              
           end-evaluate.

       600-new-acct.                                                               

           move payroll-trans-record to updated-payroll-master-record
           write updated-payroll-master-record after advancing 1 line                                

           move employee-no-trans to employee-no-out
           move 0 to prev-annual-salary-out
           move annual-salary-trans to new-annual-salary-out
           move "NEW RECORD ADDED" to type-of-action-taken

           write print-rec from payroll-trans-out after advancing 1 line

           perform 500-read-transfile.

       700-update-acct.                                                     

           move employee-no-master to employee-no-uptd
           move annual-salary-trans to annual-salary-uptd
           write updated-payroll-master-record after advancing 1 line

           move employee-no-master to employee-no-out
           move annual-salary-master to prev-annual-salary-out
           move annual-salary-trans to new-annual-salary-out
           move "RECORD UPDATED" to type-of-action-taken

           write print-rec from payroll-trans-out after advancing 1 line

           perform 500-read-transfile
           perform 400-read-old-master.
                                                                                                                                                                                       
       800-no-update.                                                  

           move payroll-master-record to updated-payroll-master-record
           write updated-payroll-master-record after advancing 1 line                               
           perform 400-read-old-master.                                

       400-read-old-master.

           read payroll-master
           at end move 'Y' to ws-old-master-eof                    
           move high-values to employee-no-master.                               
                                            
       500-read-transfile.                                             

           read payroll-trans
           at end move 'Y' to ws-transfile-eof                         
           move high-values to employee-no-trans.

       end program Program1.
