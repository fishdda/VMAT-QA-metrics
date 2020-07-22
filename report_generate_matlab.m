% Import report API classes (optional)
import mlreportgen.report.*

% Add report container (required)
rpt = Report('VMAT plan complexities','pdf');

% Add content to container (required)
% Types of content added here: title 
% page and table of contents reporters
titlepg = TitlePage;
titlepg.Title = 'Monaco VMAT plan complexities report';
titlepg.Author = 'Xiaotian Huang';
add(rpt,titlepg);
add(rpt,TableOfContents);

% Add content to report sections (optional)
% Text and formal image added to chapter
% chapter 1 ... 
chap = Chapter('RTPlan DICOM');
add(chap,'Extract Plan Information from DICOM rtplan');
add(chap,FormalImage('Image',...
    which('b747.jpg'),'Height','5in',...
    'Width','5in','Caption','Boeing 747'));
add(rpt,chap);

% chapter 2 ...
chap = Chapter('QA metrics');
add(chap,'Here is the table:');
add(chap,FormalImage('Image',...
    which('b747.jpg'),'Height','5in',...
    'Width','5in','Caption','Boeing 747'));
add(rpt,chap);


% Close the report (required)
close(rpt);
% Display the report (optional)
rptview(rpt);