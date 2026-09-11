import Dispatch
import ModelCatalog

let client = CatalogClient()
let resources = try! client.resources()

func dump_ajax_configuration(resource_name: String) {
  // print("ajax_configuration: \(resource_name)");
  let regexPattern = "\\?variant=[a-z]*$"
  let updatedString = resource_name.replacingOccurrences(
    of: regexPattern, with: "",
    options: [.regularExpression]  // Crucial option!
  )
  do {
    if let ajax = try ajaxConfiguration(forResource: updatedString) {
      print("      ajax_configuration: \(ajax)")
    }
  } catch {
    // we don't care
  }
}
func dump_m_c(r: any CatalogResource, a: any AssetBackedResource, rr: any CatalogResource) {
  do {
    let asset = try a.fetchAsset()
    print("      contents: \(asset.contents)")
    if !(asset.contents is TokenizerAssetContents) {
      print("      metadata: \(asset.metadata)")
    } else {
      print("      metadata: dunno")
    }
  } catch {
    print("      contents: failed to get \(error)")
    print("      metadata: failed to get \(error)")
  }
  print("      resource: \(r)")

  // remove trailing ?variant=[a-z]*
  let regexPattern = "\\?variant=[a-z]*$"
  let updatedString = rr.id.replacingOccurrences(
    of: regexPattern, with: "",
    options: [.regularExpression]  // Crucial option!
  )
  if (try? Catalog.resource(for: updatedString)) != nil {
    print("      resource_catalog: \(try! Catalog.resource(for: updatedString)!)")
  }
  do {
    if let ajax = try ajaxConfiguration(forResource: updatedString) {
      print("      ajax_configuration: \(ajax)")
    } else {
      print("      ajax_configuration: nil")
    }
  } catch {
    // print("      ajax_configuration: nil")
  }
}

var count: Int = 0
for r in resources {
  print("\nresource[\(count)] \(r.id): \(type(of: r))")
  count += 1

  if r is any LLMModel {
    print("  \(type(of: r)) conforms to LLMModel")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedLLMModel")
      let rr = r as! AssetBackedLLMModelBase
      dump_m_c(r: r, a: r as! any AssetBackedLLMModel, rr: rr)
    } else {
      print("    \(type(of: r)): \(r)")
      dump_ajax_configuration(resource_name: r.id)
    }
  } else if r is any LLMAdapter {
    print("  \(type(of: r)) conforms to LLMAdapter")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedLLMAdapter")
      // print("    \(type(of: r)): \(r)")
      let rr = r as! AssetBackedLLMAdapterBase
      dump_m_c(r: r, a: r as! AssetBackedLLMAdapterBase, rr: rr)
    } else {
      print("    \(type(of: r)): \(r)")
      dump_ajax_configuration(resource_name: r.id)
    }
  } else if r is any LLMDraftModel {
    print("  \(type(of: r)) conforms to LLMDraftModel")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedLLMDraftModel")
      let rr = r as! AssetBackedLLMDraftModelBase
      dump_m_c(r: r, a: r as! any AssetBackedLLMDraftModel, rr: rr)
    } else {
      print("    \(type(of: r)): \(r)")
      dump_ajax_configuration(resource_name: r.id)
    }
  } else if r is any DiffusionModel {
    print("  \(type(of: r)) conforms to DiffusionModel")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedDiffusionModel")
      let rr = r as! AssetBackedDiffusionModelBase
      dump_m_c(r: r, a: r as! any AssetBackedDiffusionModel, rr: rr)
    }
  } else if r is any DiffusionAdapter {
    print("  \(type(of: r)) conforms to DiffusionAdapter")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedDiffusionAdapter")
      let rr = r as! AssetBackedDiffusionAdapterBase
      dump_m_c(r: r, a: r as! any AssetBackedDiffusionAdapter, rr: rr)
    }
  } else if r is any DisabledUseCaseList {
    print("  \(type(of: r)) conforms to DisabledUseCaseList")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedDisabledUseCaseList")
      let rr = r as! AssetBackedDisabledUseCaseListBase
      dump_m_c(r: r, a: r as! any AssetBackedDisabledUseCaseList, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
      dump_ajax_configuration(resource_name: r.id)
    }
  } else if r is any HandwritingSynthesizer {
    print("  \(type(of: r)) conforms to HandwritingSynthesizer")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      let rr = r as! ModelCatalog.AssetBackedHandwritingSynthesizerBase
      dump_m_c(r: r, a: r as! any ModelCatalog.AssetBackedHandwritingSynthesizer, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
      dump_ajax_configuration(resource_name: r.id)
    }
  } else if r is any ImageCuratedPrompts {
    print("  \(type(of: r)) conforms to ImageCuratedPrompts")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedImageCuratedPromptsBase")
      let rr = r as! AssetBackedImageCuratedPromptsBase
      dump_m_c(r: r, a: r as! any ModelCatalog.AssetBackedImageCuratedPrompts, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
      dump_ajax_configuration(resource_name: r.id)
    }
  } else if r is any ImageFilter {
    print("  \(type(of: r)) conforms to ImageFilter")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedImageFilter")
      let rr = r as! AssetBackedImageFilterBase
      dump_m_c(r: r, a: r as! any ModelCatalog.AssetBackedImageFilter, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
      dump_ajax_configuration(resource_name: r.id)
    }
  } else if r is any ImageMagicCleanUp {
    print("  \(type(of: r)) conforms to ImageMagicCleanUp")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedImageMagicCleanUpBase")
      let rr = r as! AssetBackedImageMagicCleanUpBase
      dump_m_c(r: r, a: r as! any ModelCatalog.AssetBackedImageMagicCleanUp, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any ImageScaler {
    print("  \(type(of: r)) conforms to ImageScaler")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedImageScalerBase")
      let rr = r as! AssetBackedImageScalerBase
      dump_m_c(r: r, a: r as! any ModelCatalog.AssetBackedImageScaler, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any ImageSpatialPhotosRelive {
    print("  \(type(of: r)) conforms to ImageSpatialPhotosRelive")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedImageSpatialPhotosReliveBase")
      let rr = r as! AssetBackedImageSpatialPhotosReliveBase
      dump_m_c(r: r, a: r as! any AssetBackedImageSpatialPhotosRelive, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any ServerConfiguration {
    print("  \(type(of: r)) conforms to ServerConfiguration")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedServerConfiguration")
      let rr = r as! AssetBackedServerConfigurationBase
      dump_m_c(r: r, a: r as! any AssetBackedServerConfiguration, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any Tokenizer {
    print("  \(type(of: r)) conforms to Tokenizer")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedTokenizer")
      let rr = r as! AssetBackedTokenizerBase
      dump_m_c(r: r, a: r as! any AssetBackedTokenizer, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any ModelConfigurationReplacement {
    print("  \(type(of: r)) conforms to ModelConfigurationReplacement")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedModelConfigurationReplacement")
      let rr = r as! AssetBackedModelConfigurationReplacementBase
      dump_m_c(r: r, a: r as! any AssetBackedModelConfigurationReplacement, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any TokenInputDenyList {
    print("  \(type(of: r)) conforms to TokenInputDenyList")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedTokenInputDenyList")
      let rr = r as! AssetBackedTokenInputDenyListBase
      dump_m_c(r: r, a: r as! any AssetBackedTokenInputDenyList, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any TokenOutputDenyList {
    print("  \(type(of: r)) conforms to TokenOutputDenyList")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedTokenOutputDenyList")
      let rr = r as! AssetBackedTokenOutputDenyListBase
      dump_m_c(r: r, a: r as! any AssetBackedTokenOutputDenyList, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any TokenOutputRetainList {
    print("  \(type(of: r)) conforms to TokenOutputRetainList")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedTokenOutputRetainList")
      let rr = r as! AssetBackedTokenOutputRetainListBase
      dump_m_c(r: r, a: r as! any AssetBackedTokenOutputRetainList, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any PromptAllowList {
    print("  \(type(of: r)) conforms to PromptAllowList")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedPromptAllowListBase")
      let rr = r as! AssetBackedPromptAllowListBase
      dump_m_c(r: r, a: r as! AssetBackedPromptAllowListBase, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any ImageTokenizer {
    print("  \(type(of: r)) conforms to ImageTokenizer")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedImageTokenizerBase")
      let rr = r as! AssetBackedImageTokenizerBase
      dump_m_c(r: r, a: r as! AssetBackedImageTokenizerBase, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any EmbeddingPreprocessor {
    print("  \(type(of: r)) conforms to EmbeddingPreprocessor")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedEmbeddingPreprocessorBase")
      let rr = r as! AssetBackedEmbeddingPreprocessorBase
      dump_m_c(r: r, a: r as! AssetBackedEmbeddingPreprocessorBase, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any EmbeddingDenyList {
    print("  \(type(of: r)) conforms to EmbeddingDenyList")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedEmbeddingDenyListBase")
      let rr = r as! AssetBackedEmbeddingDenyListBase
      dump_m_c(r: r, a: r as! AssetBackedEmbeddingDenyListBase, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any AppleDeviceTracking {
    print("  \(type(of: r)) conforms to AppleDeviceTracking")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedAppleDeviceTrackingBase")
      let rr = r as! AssetBackedAppleDeviceTrackingBase
      // dump_m_c(r: r, a: r as! any AssetBackedAppleDeviceTrackingBase, rr: rr)
      dump_m_c(r: r, a: r as! AssetBackedAppleDeviceTrackingBase, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any Motion {
    print("  \(type(of: r)) conforms to Motion")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedMotionBase")
      let rr = r as! AssetBackedMotionBase
      dump_m_c(r: r, a: r as! AssetBackedMotionBase, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r is any MotionAdapter {
    print("  \(type(of: r)) conforms to MotionAdapter")
    // print("  \(type(of: r)): \(r)")
    if r.assetBacked {
      print("    \(type(of: r)) conforms to AssetBackedMotionAdapterBase")
      let rr = r as! AssetBackedMotionAdapterBase
      // dump_m_c(r: r, a: r as! any AssetBackedMotionBase, rr: rr)
      dump_m_c(r: r, a: r as! AssetBackedMotionAdapterBase, rr: rr)
    } else {
      print("  \(type(of: r)): \(r)")
    }
  } else if r.assetBacked {
    print("  assetBacked: \(r.assetBacked)")
    if r is any AssetBackedResource {
      print("  assetBackedresource: \(r)")
    }
  } else {
    print("  assetBacked: \(r.assetBacked)")
  }
}
