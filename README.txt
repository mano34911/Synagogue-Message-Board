SYNAGOGUE MESSAGE BOARD
========================

Main website files
------------------
index.html
admin.html
login.html
register.html
master-admin.html
payment.html
404.html
manifest.json
service-worker.js

Firebase / Android
------------------
google-services.json

Supabase database files
-----------------------
database-setup.txt
paypal-database-update.txt

Supabase Edge Functions
-----------------------
create-paypal-subscription.txt
paypal-webhook.txt

When deployed inside Supabase CLI structure:

supabase/
  functions/
    create-paypal-subscription/
      index.ts
    paypal-webhook/
      index.ts

Important
---------
1. Run database-setup.txt first in Supabase SQL Editor.
2. Run paypal-database-update.txt after it.
3. Create your first account with register.html.
4. Approve the first master admin using the UPDATE statement at the bottom
   of database-setup.txt.
5. Configure the PayPal secrets before deploying the Edge Functions.
6. Enable GitHub Pages from the repository root / main branch.
7. Keep service-worker.js in the repository root.
8. Keep manifest.json in the repository root.

Main pages
----------
index.html          Public synagogue message board
login.html          Login page
register.html       New synagogue/member registration
admin.html          Synagogue board administration
master-admin.html   Master user/member administration
payment.html        Subscription/payment page

Supabase project
----------------
https://chcfhxkggbrlxaopnfum.supabase.co

Firebase project
----------------
Project ID: synagogueboard
Android package: com.bethtorah.messageboard
