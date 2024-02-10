# Çiftlik Oyunu Projesi

Bu proje, Ethereum blok zinciri üzerinde çalışan basit bir çiftlik oyununu içerir. Projede, oyuncuların çiftlikte inek satın almasını, inekleri beslemesini, süt sağmasını ve çiftlikteki faaliyetleri yönetmesini sağlayan akıllı sözleşmeler yer almaktadır.

## Akıllı Sözleşmeler

Projede, aşağıdaki akıllı sözleşmeler kullanılmıştır:

- **Farm.sol**: Çiftlik faaliyetlerini yöneten ana akıllı sözleşmedir. İnek satın alma, süt sağlama, ürün toplama gibi işlevleri içerir.
- **Cow.sol**: Çiftlikteki ineklerin özelliklerini ve davranışlarını yöneten akıllı sözleşmedir.
- **CowNFT.sol**: Ineklerin ERC721 standardında tokenlaştırılmış sürümünü temsil eder ve inek NFT'lerinin oluşturulmasını ve yönetilmesini sağlar.
- **Animals.sol**: Temel hayvan yapılarını ve işlevlerini içeren bir kütüphane akıllı sözleşmesidir.
- **CowToken.sol**: ERC20 standartında bir token olan "Cow" adında bir çiftlik tokenıdır. Toplam arzı 100 milyon olup, %50'si kilitlidir.

## Nasıl Başlanır

Projeyi yerel bir Ethereum geliştirme ortamında veya bir test ağı üzerinde çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

1. Repoyu klonlayın: `git clone https://github.com/kullanici/çiftlik-oyunu.git`
2. Gerekli bağımlılıkları yükleyin: `npm install`
3. Geliştirme ortamını başlatın: `npm start`

## Katkıda Bulunma

Katkıda bulunmak isterseniz, lütfen bir çekme isteği göndermeden önce değişikliklerinizi tartışmak için bir konu açın.

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Daha fazla bilgi için [LİSANS](LICENSE) dosyasına bakın.
