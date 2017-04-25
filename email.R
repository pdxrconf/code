library(gmailr)
library(dplyr)
library(googlesheets)

# get googlesheet data
sheet <- gs_title("CascadiaRConf-Submissions")
dat <- gs_read(sheet)
dat <- dat[-c(1,2), c('First Name', 'Email', 'Talk Title')]
datlist <- apply(dat, 1, as.list)
datlist <- datlist[56:length(datlist)]

# send emails
email_text <- "Hi %s

This is a quick note to tell you we received your talk submission to CascadiaRConf.

Thank you for submitting your talk proposal '%s'.

We'll be notifying people if they're talk is accepted or not late this
week or early the week after.

Sincerely,
CascadiaRConf Organizers
(sent using `gmailr`)
"

lapply(datlist, function(z) {
  mime() %>%
    from("pdxrlang@gmail.com") %>%
    to(z$Email) %>%
    #to("myrmecocystus@gmail.com") %>%
    subject("Confirmation: We received your talk submission for CascadiaRConf") %>%
    text_body(sprintf(email_text, z$`First Name`, z$`Talk Title`)) %>%
    send_message()
})

