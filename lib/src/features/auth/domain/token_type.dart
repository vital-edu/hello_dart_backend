enum TokenType {
  accessToken('accessToken'),
  refreshToken('refreshToken');

  final String value;

  const TokenType(this.value);
}
