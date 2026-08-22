import jsQR from 'jsqr'

export async function readQrFromFile(file) {
  const bitmap = await createImageBitmap(file)
  const canvas = document.createElement('canvas')
  canvas.width = bitmap.width
  canvas.height = bitmap.height
  const ctx = canvas.getContext('2d')
  ctx.drawImage(bitmap, 0, 0)
  const image = ctx.getImageData(0, 0, canvas.width, canvas.height)
  const code = jsQR(image.data, image.width, image.height, {
    inversionAttempts: 'attemptBoth',
  })
  if (!code?.data) {
    throw new Error('No QR code found in that image. Try a sharper photo of the Fayda card.')
  }
  return code.data
}
