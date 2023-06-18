void firebaseConnect() {
  fconfig.api_key = firebaseKey;
  fconfig.database_url = firebaseHost;
  fauth.user.email = firebaseAuthEmail;
  fauth.user.password = firebaseAuthPassword;
  fbdo.setBSSLBufferSize(8192, 8192);
  fbdo.setResponseSize(8192);
  Firebase.begin(&fconfig, &fauth);
}