pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION  = 'us-east-1'
        S3_BUCKET           = 'contact-form-frontend-393aca8c'
        SUBMIT_LAMBDA       = 'contact-form-submit-dev'
        GET_CONTACTS_LAMBDA = 'contact-form-get-contacts-dev'
        CLOUDFRONT_ID       = 'ESBFME97SJMK1'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Kod GitHub dan çekiliyor...'
                checkout scm
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Backend testleri çalıştırılıyor...'
                sh '''
                    python3 -m py_compile backend/submit_contact.py
                    python3 -m py_compile backend/get_contacts.py
                    echo "✅ Syntax kontrolü geçti!"
                '''
            }
        }

        stage('Deploy Frontend') {
            steps {
                echo '🚀 Frontend S3 e deploy ediliyor...'
                sh '''
                    aws s3 sync frontend/ s3://${S3_BUCKET}/ --delete
                    echo "✅ Frontend deploy edildi!"
                '''
            }
        }

        stage('Deploy Backend') {
            steps {
                echo '⚡ Lambda fonksiyonları güncelleniyor...'
                sh '''
                    zip -j submit_contact.zip backend/submit_contact.py
                    aws lambda update-function-code \\
                        --function-name ${SUBMIT_LAMBDA} \\
                        --zip-file fileb://submit_contact.zip

                    zip -j get_contacts.zip backend/get_contacts.py
                    aws lambda update-function-code \\
                        --function-name ${GET_CONTACTS_LAMBDA} \\
                        --zip-file fileb://get_contacts.zip

                    echo "✅ Lambda fonksiyonları güncellendi!"
                '''
            }
        }

        stage('Invalidate CloudFront') {
            steps {
                echo '🌐 CloudFront cache temizleniyor...'
                sh '''
                    aws cloudfront create-invalidation \\
                        --distribution-id ${CLOUDFRONT_ID} \\
                        --paths "/*"
                    echo "✅ CloudFront cache temizlendi!"
                '''
            }
        }

    }

    post {
        success {
            echo '🎉 Pipeline başarıyla tamamlandı! Uygulama canlıda.'
        }
        failure {
            echo '❌ Pipeline başarısız! Logları kontrol et.'
        }
    }
}