desc 'Generate a private key'
rule '.private.pem' do |r|
  sh 'openssl', 'genrsa',
    '-out', r.name,
    '4096'
end

desc 'Generate a certificate signing request (CSR) from the private key'
rule '.csr' => '.private.pem' do |r|
  sh 'openssl', 'req',
    '-sha256', '-new',
    '-key', r.source,
    '-out', r.name,
    '-subj', "/CN=#{r.name.pathmap('%n')}" # base file name without extension
end

desc 'Create and sign a certificate from a CSR and private key'
rule '.crt' => ['.private.pem', '.csr'] do |r|
  sh 'openssl', 'x509', '-req',
    '-sha256',
    '-days', '365',
    '-out', r.name,
    '-outform', 'der',
    '-in', r.sources.last,
    '-signkey', r.sources.first
end