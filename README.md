# LineageOS hlte (Galaxy Note 3 - SM-N9005) Build Kit

## Kurulum
1. Bu zip'in içeriğini yeni/boş bir GitHub repo'nun köküne çıkar (extract).
2. `git add . && git commit -m "init" && git push`
3. GitHub'da repo > **Actions** sekmesine gir, "Build LineageOS for hlte" workflow'unu seç.
4. **Run workflow** butonuna bas, branch olarak `lineage-18.1` bırak (veya değiştir).

## Özelleştirme dosyalarını eklemek (opsiyonel, şimdi veya sonra)
`customization/` klasörüne şunları koy:
- `bootanimation.zip` → açılış animasyonu
- `wallpaper.png` → varsayılan duvar kağıdı
- `prebuilt-apps/*.apk` → ön yüklü gelmesini istediğin uygulamalar

Hiçbirini koymazsan script onları atlar, hata vermez — yani boş bırakıp da
derlemeyi deneyebilirsin.

`customization/apply.sh` içinde build.prop satırları var (DPI, model adı vb.),
istersen direkt o dosyayı açıp değiştirebilirsin:
```
ro.sf.lcd_density=320
ro.product.model=SM-N9005-Custom
```

## ÖNEMLİ UYARILAR
- `hlte` resmi olarak artık bakım görmüyor. `lineage-18.1` branch'indeki
  device/vendor/kernel depolarının hâlâ erişilebilir olduğunu derlemeden
  ÖNCE şu adreslerden kontrol et:
  - https://github.com/LineageOS/android_device_samsung_hlte
  - https://github.com/LineageOS/android_device_samsung_msm8974-common
  - https://github.com/LineageOS/android_kernel_samsung_msm8974
  - https://github.com/TheMuppets/proprietary_vendor_samsung
  Depo taşınmış/arşivlenmişse `local_manifests/roomservice.xml` içindeki
  revision veya repo adını güncellemen gerekir.

- GitHub'ın ÜCRETSİZ runner'ları sınırlı disk (genişletilse de ~80-90GB) ve
  6 saat süre sınırına sahip. Android derlemesi bu sınırlara çok yakın/üstünde
  kalabilir. İlk denemede "no space left" veya timeout hatası alırsan:
  - ccache boyutunu küçült
  - veya self-hosted runner kullanmayı düşün (kendi bilgisayarını runner yap)

- Derleme başarılı olursa çıktı hem Actions sekmesinde "Artifacts" olarak
  hem de repo'nun "Releases" kısmında otomatik oluşturulan bir release
  içinde `.zip` olarak görünecek.

## Sorun çıkarsa
Actions sekmesindeki log çıktısını (özellikle hata veren adımı) kopyalayıp
bana gönder, birlikte bakarız.
